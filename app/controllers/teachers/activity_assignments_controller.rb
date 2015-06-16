class ActivityAssignmentsController < ApplicationController
  include QuillAuthentication
  respond_to :json

  before_filter :teacher!
  before_action :set_classroom_activities, only: [:update, :destroy]

  def update
    @classroom_activities.each do |ca|
      ca.update_attributes due_date: params[:due_date]
    end
    render json: {}
  end

  def destroy
    @classroom_activities.destroy_all
  end

  def set_classroom_activities
    @classroom_activities = ClassroomActivity.where(unit_id: params[:unit_id], 
                                                    activity_id: params[:activity_assignment_id])
  end
end