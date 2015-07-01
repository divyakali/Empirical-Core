class Api::V1::ConceptsController < ApplicationController
  def index
    render json: Concept.all
  end
end