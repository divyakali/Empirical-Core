class ConceptChildRelation < ActiveRecord::Base
  attr_accessor :parent, :child, :parent_id, :child_id
  belongs_to :parent, class_name: 'Concept', inverse_of: :concept_child_relations
  belongs_to :child, class_name: 'Concept',  inverse_of: :concept_parent_relations
end