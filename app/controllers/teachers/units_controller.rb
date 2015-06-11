class Teachers::UnitsController < ApplicationController
  respond_to :json
  before_filter :teacher!
  before_action :set_unit, only: [:update, :destroy]

  # Request format for CREATE and UPDATE:
  #   unit: {
  #     name: string
  #     classrooms: [{
  #       id: int
  #       all_students: boolean
  #       student_ids: [int]
  #     }]
  #     activities: [{
  #       id: int
  #       due_date: string
  #     }]
  #   }

  def create
    unit = Unit.create name: unit_params[:name]
    unit.create_new_cas unit_params[:classrooms], unit_params[:activities]
    # activity_sessions in the state of 'unstarted' are automatically created in an after_create callback in the classroom_activity model
    AssignActivityWorker.perform_async(current_user.id) # current_user should be the teacher
    render json: {}
  end

  def update
    @unit.update_unit unit_params[:name], unit_params[:classrooms], unit_params[:activities]
    render json: {}
  end

  def index
    render json: (Unit.index_for_activity_planner(current_user))
  end

  def destroy
    @unit.destroy
    render json: {}
  end

  private

  def set_unit
    @unit = Unit.find params[:id]
  end

  def unit_params
    params[:unit][:classrooms].each{|c| c[:student_ids] ||= []} # rails converts empty json arrays into nil, which is undesirable
    params.require(:unit).permit(:name, classrooms: [:id, :all_students, :student_ids => []], activities: [:id, :due_date])
  end
end