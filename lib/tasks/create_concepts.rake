namespace :concepts do
  desc 'make demo accounts'
  task :create => :environment do
    create_concepts
  end
end

def create_concepts
  file = Rails.root.join('db', 'concepts_3_test_data.csv')

  arr_arr = []

  CSV.foreach(file) do |row|
    c1_name = row[0]
    c0_name = row[1]
    rq_id = row[2]

    c0_old = Concept.find_by name: c0_name
    c1 = Concept.find_or_create_by name: c1_name

    created_new_c0 = ''

    if c0_old.nil? or c0_old.parents.where(id: c1.id).empty?
      if c0_old.nil? or c0_old.parents.any?
        c0_new = Concept.create name: c0_name
        c0_new.add_parent c1
        created_new_c0 = 'YES'
        c0 = c0_new
      else
        c0_old.add_parent c1
        c0 = c0_old
      end
    end

    c2 = Concept.find_or_create_by name: 'Grammar'
    c1.add_parent c2

    arr = [rq_id, c0.id, created_new_c0]
    arr_arr.push arr
  end

  output = Rails.root.join('db', 'concepts_3_output.csv')
  CSV.open(output, 'wb') do |csv|
    arr_arr.each do |arr|
      csv << arr
    end
  end
end