require 'rails_helper'
require 'spec_helper'
require 'rake'


describe "concepts" do
  before :all do
    Rake.application.rake_require 'tasks/concepts'
    Rake::Task.define_task(:environment)
  end

  it "works" do
    test_method

  end

end