class CreateConceptChildRelations < ActiveRecord::Migration
  def change
    create_table :concept_child_relations do |t|
      t.belongs_to :parent
      t.belongs_to :child
    end
  end
end
