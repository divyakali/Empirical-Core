namespace :concepts do
  desc 'create concepts'
  task :create => :environment do

    test_method

  end


  def test_method
    rows = CSV.read("#{__dir__}/data/concepts.csv")
    header = rows[0]
    content = rows[1..-1]
    puts "\n header : \n #{header.to_json} \n content: #{content.to_json}"

    content.each{|row| process_row(row)}
  end

  def process_row row
    concept_at_level_2 = row[0]
    concept_at_level_1 = row[1]
    concept_at_level_0 = row[2]

    concept_class = ConceptClass.find_or_create_by name: concept_at_level_2
    concept_category = concept_class.concept_categories.find_or_create_by name: concept_at_level_1
    concept_tag = concept_category.concept_tags.find_or_create_by name: concept_at_level_0

=begin

KRIS :
concept_class    --> concept_tag
concept_category --> concept_tag_results
concept_tag      --> concept_tag_results

MARCELLO :
concept_class    --> concept_category
concept_category --> concept_tag
concept_tag      --> concept_tag_result


=end
  end

end