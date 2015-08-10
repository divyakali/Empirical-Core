class Api::V1::ActivitiesController < Api::ApiController
  include Swagger::Blocks

  doorkeeper_for :create, :update, :destroy
  before_action :find_activity, except: [:index, :create]

  swagger_path '/activities/{id}' do
    operation :get do
      key :description, 'Returns a single activity'
      key :operationId, 'findActivityById'
      key :tags, [
        'pet'
      ]
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'ID of activity to fetch'
        key :required, true
        key :type, :integer
        key :format, :int64
      end
      response 200 do
        key :description, 'activity response'
        schema do
          key :'$ref', :ActivitySerializer
        end
      end
      # response :default do
      #   key :description, 'unexpected error'
      #   schema do
      #     key :'$ref', :ErrorModel
      #   end
      # end
    end
  end

  def index
    # FIXME: original API doesn't support index
    @activities = Activity.all
  end

  # GET
  def show
    render json: @activity, meta: {status: 'success', message: nil, errors: nil}
  end

  # PATCH, PUT
  def update
    if @activity.update(activity_params)
      @status = :success
      @message = "Activity Updated"
    else
      @status = :failed
      @message = "Activity Update Failed"
    end

    render json: @activity, meta: {status: @status, message: @message, errors: @activity.errors}

  end

  # POST
  def create
    activity = Activity.new(activity_params)
    activity.set_owner(current_user) if activity.ownable?

    if activity.valid? && activity.save
      @status = :success
      @message = "Activity Created"
    else
      @status = :failed
      @message = "Activity Create Failed"
    end

    render json: @activity, meta: {status: @status, message: @message, errors: @activity.errors}
  end

  # DELETE
  def destroy

    if @activity.destroy!
      render json: Activity.new, meta: {status: 'success', message: "Activity Destroy Successful", errors: nil}
    else
      render json: @activity, meta: {status: 'failed', message: "Activity Destroy Failed", errors: @activity.errors}
    end

  end

  private

  def find_activity
    @activity = Activity.find_by_uid!(params[:id])
  end

  def activity_params
    params.delete(:access_token)
    params.delete(:activity) # read only and therefore static
    @data = params.delete(:data) # the thing likely to be persisted

    params.except(:id).permit(:name, :description, :activity_classification_id, :topic_id, :flags).merge(data: @data).reject {|k,v| v.nil? }
  end

end
