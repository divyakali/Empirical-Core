class ConceptClass < ActiveRecord::Base
  # remove 'has_many concept_tags'
  # remove 'has_many concept_tag_results, through :concept_tags'
  # add : 'has_many concept_categories'
  has_many :concept_tags
  has_many :concept_tag_results, through: :concept_tags


  def self.for_concept_tag_results(concept_tag_results)
    joins(:concept_tags => :concept_tag_results).where('concept_tag_results.id' => concept_tag_results).uniq
  end
  # change above method to :
  # joins(:concept_categories => [:concept_tags => :concept_tag_results]).where(.....)

end