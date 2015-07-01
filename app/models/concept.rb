class Concept < ActiveRecord::Base
  validates :name, presence: true
  has_many :concept_child_relations, class_name: 'ConceptChildRelation', inverse_of: :parent, foreign_key: "parent_id"
  has_many :concept_parent_relations, class_name: 'ConceptChildRelation', inverse_of: :child, foreign_key: "child_id"

  def children
    Concept.joins("JOIN concept_child_relations ON concept_child_relations.child_id = concepts.id")
           .where("concept_child_relations.parent_id = #{self.id}")
  end

  def parents
    Concept.joins("JOIN concept_child_relations ON concept_child_relations.parent_id = concepts.id")
            .where("concept_child_relations.child_id = #{self.id}")
  end

  def add_parent parent
    establish_parent_child_relation parent, self
  end

  def add_child child
    establish_parent_child_relation self, child
  end

  def establish_parent_child_relation parent, child
    return if parent.children.where(id: child.id).any?
    cr = ConceptChildRelation.new
    parent.concept_child_relations << cr
    child.concept_parent_relations << cr
  end

end