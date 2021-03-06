class Scorebook
  SCORES_PER_PAGE = 200
  def initialize(teacher)
    @teacher = teacher
  end

  def scores(current_page=1, classroom_id=nil, unit_id=nil, begin_date=nil, end_date=nil)
    results = student_activity_sessions(classroom_id)
    results = filter_by_unit(results, unit_id)
    results = filter_by_dates(results, begin_date, end_date)
    results = paginate(results, current_page)

    is_last_page = (results.length < SCORES_PER_PAGE)

    x1 = results.group_by(&:user_id)

    x2 = []
    x1.each do |user_id, scores|
      those_completed, those_not_completed = scores.partition{|s| s.completed_at.present? }
      those_completed.sort_by!{|s| s.completed_at}
      those_not_completed.sort_by!{|s| (s.classroom_activity.present? and s.classroom_activity.due_date.present?) ? s.classroom_activity.due_date : (Date.today - 10000)}

      scores = those_completed.concat those_not_completed

      formatted_scores = scores.map do |s|
        present(s)
      end
      ele = {
        user: User.find(user_id),
        results: formatted_scores
      }
      x2.push ele
    end

    x2 = x2.sort_by{|x2| x2[:user].sorting_name}
    all = x2

    [all, is_last_page]
  end

  private

  def student_activity_sessions(classroom_id)
    if classroom_id.present?
      users = Classroom.find(classroom_id).students
    else
      users = @teacher.classrooms.map(&:students).flatten.compact.uniq
    end

    # Find all the 'final' activity sessions for all the students in all the classrooms
    results = ActivitySession.select("users.name, activity_sessions.id, activity_sessions.percentage,
                                #{User.sorting_name_sql}")
                              .includes(:user, :activity => [:classification, :topic => [:section, :topic_category]])
                              .references(:user)
                              .where(user: users)
                              .where('(activity_sessions.is_final_score = true) or ((activity_sessions.completed_at IS NULL) and activity_sessions.is_retry = false)')

    results
  end

  def filter_by_unit(results, unit_id)
    if unit_id.present?
      classroom_activity_ids = Unit.find(unit_id).classroom_activities.map(&:id)
      results = results.where(classroom_activity_id: classroom_activity_ids)
    end
    results
  end

  def filter_by_dates(results, begin_date, end_date)
    if (begin_date.present? or end_date.present?) then results = results.where("activity_sessions.completed_at IS NOT NULL") end

    if begin_date.present?
      results = results.where("activity_sessions.completed_at > ?", (begin_date.to_date - 1.day))
    end
    if end_date.present? 
      results = results.where("activity_sessions.completed_at < ?", (end_date.to_date + 1.day) )
    end
    results
  end

  def paginate(results, current_page)
    results.order('sorting_name, activity_sessions.completed_at, activity_sessions.id')
                      .limit(SCORES_PER_PAGE)
                      .offset( (current_page -1 )*SCORES_PER_PAGE)
  end

  # TODO: This belongs in the view layer.
  def present(activity_session)
    {
      id: activity_session.id,
      percentage: activity_session.percentage,
      due_date_or_completed_at_date: activity_session.display_due_date_or_completed_at_date,
      activity: (ActivitySerializer.new(activity_session.activity)).as_json(root: false),
      concept_results: activity_session.concept_results.map {|result| ConceptResultSerializer.new(result).as_json(root: false) }
    }
  end
end