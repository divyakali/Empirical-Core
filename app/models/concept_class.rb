class ConceptClass < ActiveRecord::Base
  # remove both associations below
  has_many :concept_tags
  has_many :concept_tag_results, through: :concept_tags


  # add : 'has_many concept_categories'

  def self.for_concept_tag_results(concept_tag_results)
    # change below expression to :
    # joins(:concept_categories => {:concept_tags => :concept_tag_results}).where('concept_tag_results.id' => concept_tag_results).uniq
    joins(:concept_tags => :concept_tag_results).where('concept_tag_results.id' => concept_tag_results).uniq
  end

end