require 'rails_helper'
require 'spec_helper'
require 'rake'

describe 'create concepts' do
  before :all do
    Rake.application.rake_require 'tasks/create_concepts'
    Rake::Task.define_task(:environment)
    create_concepts 'concepts_3_test_data.csv'
  end

  def helper1 parent_name
    ia = Concept.find_by name: parent_name
    ia_has_one_child = (ia.children.length == 1)
    child = ia.children.first
    child_has_name_a = (child.name == 'A')
    child_has_one_parent = (child.parents.length == 1)
    arr = [ia_has_one_child, child_has_name_a, child_has_one_parent]
    arr
  end

  it 'creates 3 distinct concepts with the name A' do
    cs = Concept.where name: 'A'
    expect(cs.count).to eq(3)
  end

  it 'creates one concept with name A that has exactly 1 parent : Indefinite Articles' do
    arr = helper1 'Indefinite Articles'
    expect(arr).to_not include(false)
  end

  it 'creates one concept with name A that has exactly 1 parent : Indefinite Articles 2' do
    arr = helper1 'Indefinite Articles 2'
    expect(arr).to_not include(false)
  end

  it 'creates one concept with name A that has exactly 1 parent : Indefinite Articles 3' do
    arr = helper1 'Indefinite Articles 3'
    puts Concept.all.to_json
    expect(arr).to_not include(false)
  end

end