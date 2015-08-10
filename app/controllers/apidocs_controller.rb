class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'Quill.org'
      key :description, 'foobar'
      key :termsOfService, 'foobar'
      contact do
        key :name, 'Quill'
      end
      license do
        key :name, 'AGPL'
      end
    end
    tag do
      key :name, 'activity'
      key :description, 'Activities operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://swagger.io'
      end
    end
    key :host, 'quill.org'
    key :basePath, '/api/v1'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    Api::V1::ActivitiesController,
    ActivitySerializer,
    self,
  ].freeze

  def index
    respond_to do |format|
      format.html
      format.json { render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES) }
    end
  end
end