namespace :concepts do
  desc 'make demo accounts'
  task :create => :environment do
    create_concepts 'concepts_3.csv'
  end
end

def create_concepts file_name
  file = Rails.root.join('db', file_name)

  arr_arr = []

  CSV.foreach(file) do |row|
    c1_name = row[0]
    c0_name = row[1]
    rq_id = row[2]

    c0_old = Concept.find_by name: c0_name
    c1 = Concept.find_or_create_by name: c1_name


    if c0_old.nil?
      do_anything = true
      create_new_c0 = true
    elsif c0_old.parents.empty?
      do_anything = true
      create_new_c0 = false
    else
      if c0_old.parents.where(id: c1.id).empty?
        do_anything = true
        create_new_c0 = true
      else
        do_anything = false
      end
    end

    if do_anything
      if create_new_c0
        c0 = Concept.create name: c0_name
        created_new_c0 = "YES"
      else
        c0 = c0_old
        created_new_c0 = ""
      end
      c0.add_parent c1
      c2 = Concept.find_or_create_by name: 'Grammar'
      c1.add_parent c2

      arr = [rq_id, c0.id, created_new_c0]
      arr_arr.push arr
    end
  end

  output = Rails.root.join('db', 'concepts_3_output.csv')
  CSV.open(output, 'wb') do |csv|
    arr_arr.each do |arr|
      csv << arr
    end
  end
end