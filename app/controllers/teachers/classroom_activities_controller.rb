class Teachers::ClassroomActivitiesController < ApplicationController
  include QuillAuthentication
  respond_to :json

  before_filter :teacher!
  before_filter :authorize!

private

  def authorize!
    @classroom_activity = ClassroomActivity.find params[:id]
    if @classroom_activity.classroom.teacher != current_user then auth_failed end
  end

end
