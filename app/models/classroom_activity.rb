class ClassroomActivity < ActiveRecord::Base
  belongs_to :classroom
  belongs_to :activity
  belongs_to :unit, touch: true
  has_one :topic, through: :activity
  has_many :activity_sessions, dependent: :destroy

  scope :with_topic, ->(tid) { joins(:topic).where(topics: {id: tid}) }

  after_create :assign_to_students

  def due_date_string= val
    self.due_date = Date.strptime(val, Time::DATE_FORMATS[:quill_default])
  end

  def due_date_string
    due_date.try(:to_formatted_s, :quill_default)
  end

  def session_for user
    session_for_by_id user.id
  end

  def session_for_by_id user_id
    ass = activity_sessions.where(user_id: user_id, activity: activity).order(created_at: :asc)
    as = if ass.any? then ass.first else activity_sessions.create(user_id: user_id, activity: activity) end
    as
  end

  def for_student? student
    return true if assigned_student_ids.nil? || assigned_student_ids.empty?
    assigned_student_ids.include?(student.id)
  end

  def students
    if assigned_student_ids.try(:any?)
      User.find(assigned_student_ids)
    else
      classroom.students
    end
  end

  def completed
    activity_sessions.completed.includes([:user, :activity]).joins(:user).where('users.role' == 'student')
  end

  def scorebook
    @score_book = {}
    completed.each do |activity_session|

      new_score = {activity: activity_session.activity, session: activity_session, score: activity_session.percentage}

      user = @score_book[activity_session.user.id] ||= {}

      user[activity_session.activity.uid] ||= new_score
    end

    @score_book
  end

  class << self
    # TODO: this method assumes that a student is only in ONE classroom.
    def create_session(activity, options = {})
      classroom_activity = where(activity_id: activity.id, classroom_id: options[:user].classroom.id).first_or_create
      classroom_activity.activity_sessions.create!(user: options[:user])
    end
  end

  # used in unit.update_unit
  def update_ca (incoming_student_ids, new_due_date)
    # MUST DO THE BELOW IN THE EXACT FOLLOWING ORDER
    self.update_relevant_activity_sessions incoming_student_ids
    self.update_attributes(due_date: new_due_date, assigned_student_ids: incoming_student_ids)
  end

  # used in self.update_ca

  def update_relevant_activity_sessions incoming_student_ids
    # destroy the activity_sessions of those students who are no longer selected
    # create new activity_sessions for those who are newly selected
    formerly  = self.get_assigned_student_ids self.assigned_student_ids
    should_be = self.get_assigned_student_ids incoming_student_ids

    extant_student_ids_to_be_removed = formerly  - should_be
    new_student_ids_to_be_added      = should_be - formerly

    self.activity_sessions.where(user_id: extant_student_ids_to_be_removed).destroy_all
    new_student_ids_to_be_added.each{|student_id| self.session_for_by_id(student_id)}
  end


  protected



  def get_assigned_student_ids ids
    # dont simply return self.assigned_student_ids or self.classroom.students.ids
    # this method is written this exact particular way because of how its used in #update_relevant_activity_sessions
    # is not the same as #assigned_students.pluck(:id)
    (ids.nil? or ids.empty?) ?  self.classroom.students.pluck(:id) : ids
  end

  # after_create callback :
  def assign_to_students
    students.each do |student|
      session_for(student)
    end
  end
end