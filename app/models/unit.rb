class Unit < ActiveRecord::Base

  belongs_to :classroom
  has_many :classroom_activities, dependent: :destroy
  has_many :activities, through: :classroom_activities
  has_many :topics, through: :activities

  def self.for_standards_progress_report(teacher, filters)
    with(best_activity_sessions: ActivitySession.for_standards_report(teacher, filters))
      .select("units.id as id, units.name as name")
      .joins('JOIN classroom_activities ON classroom_activities.unit_id = units.id')
      .joins('JOIN best_activity_sessions ON best_activity_sessions.classroom_activity_id = classroom_activities.id')
      .group('units.id')
      .order("units.created_at asc, units.name asc") # Try order by creation date, fall back to name)
  end

  # called in UnitsController#index
  def self.index_for_activity_planner(teacher)
    cas = teacher.classrooms.map(&:classroom_activities).flatten
    units = cas.group_by{|ca| ca.unit_id}
    arr = units.map do |unit_id, classroom_activities|

      x1 = classroom_activities
              .reject{|ca| ca.due_date.nil?}
              .compact
              .sort{|a, b| a.due_date <=> b.due_date}
              .map{|ca| (ClassroomActivitySerializer.new(ca)).as_json(root: false)}

      classrooms = x1.map{|ca| ca[:classroom]}.compact.uniq

      assigned_student_ids = []

      classroom_activities.each do |ca|
        if ca.assigned_student_ids.nil? or ca.assigned_student_ids.empty?
          y = ca.classroom.students.map(&:id)
        else
          y = ca.assigned_student_ids
        end
        assigned_student_ids = assigned_student_ids.concat(y)
      end

      num_students_assigned = assigned_student_ids.uniq.length

      x1 = x1.uniq{|y| y[:activity_id] }

      ele = {unit: Unit.find(unit_id), classroom_activities: x1, num_students_assigned: num_students_assigned, classrooms: classrooms}
      ele
    end
  end

  # CREATING
  # these are called in #create and #update in UnitsController

  def create_new_cas_for_new_incoming_classrooms new_incoming_cs, incoming_as
    create_new_cas new_incoming_cs, incoming_as
  end

  def create_new_cas_for_new_incoming_activities new_incoming_as, incoming_cs
    create_new_cas incoming_cs, new_incoming_as
  end

  def create_new_cas cs, as # c = classroom, a = activity ; NOTE: these are not records, but hashes incoming from an ajax post
    cs.each do |c|
      as.each do |a|
        self.classroom_activities.create(classroom_id: c[:id],
                                         activity_id: a[:id],
                                         assigned_student_ids: c[:student_ids],
                                         due_date: a[:due_date])
      end
    end
  end

  # UPDATING
  def update_unit name, incoming_cs, incoming_as # c = classroom, a = activity
    self.update_attributes(name: name)

    extant_cas_to_be_updated, extant_cas_to_be_removed = self.split_extant_cas(incoming_cs,
                                                                               incoming_as)
    extant_cas_to_be_removed.map(&:destroy)

    extant_incoming_cs, new_incoming_cs = self.split_incoming incoming_cs, 'classroom_id'
    extant_incoming_as, new_incoming_as = self.split_incoming incoming_as, 'activity_id'

    self.update_extant_cas(extant_cas_to_be_updated,
                           extant_incoming_cs,
                           extant_incoming_as)

    self.create_new_cas new_incoming_cs,      incoming_as
    self.create_new_cas     incoming_cs,  new_incoming_as
  end

  def split_incoming data, type_id
    extant_ids = self.classroom_activities.pluck(type_id.to_sym)
    split = data.partition do |d|
      extant_ids.include?(d[:id])
    end
  end

  def split_extant_cas incoming_cs, incoming_as
    split_extant_cas = self.classroom_activities.partition do |ca|
      p = incoming_cs.map{|c| c[:id]}.include?(ca.classroom_id)
      q = incoming_as.map{|a| a[:id]}.include?(ca.activity_id)
      (p & q)
    end
  end

  # ACTUALLY UPDATING RECORDS
  def update_extant_cas (extant_cas_to_be_updated,
                         extant_incoming_cs,
                         extant_incoming_as)
    extant_cas_to_be_updated.each do |ca|
      relevant_incoming_classroom = extant_incoming_cs.find{|c| c[:id] == ca.classroom_id}
      incoming_student_ids = relevant_incoming_classroom[:student_ids]
      relevant_incoming_activity  = extant_incoming_as.find{|a| a[:id] == ca.activity_id}
      new_due_date = relevant_incoming_activity[:due_date]
      ca.update_ca(incoming_student_ids, new_due_date)
    end
  end
end