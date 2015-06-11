require 'rails_helper'

describe Unit, type: :model do
	let!(:classroom) {FactoryGirl.create(:classroom)}
	let!(:student) {FactoryGirl.create(:student, classroom: classroom)}
	let!(:classroom_activity) {FactoryGirl.create(:classroom_activity_with_activity, classroom: classroom)}
	let!(:unit) {FactoryGirl.create :unit, classroom_activities: [classroom_activity]}

	describe '#destroy' do

		it 'destroys associated classroom_activities' do
			unit.destroy
			expect(ClassroomActivity.where(id: classroom_activity.id)).to be_empty
		end
	end

  describe "getting units for the progress report" do
    let!(:teacher) { FactoryGirl.create(:teacher) }
    let(:section_ids) { [sections[0].id, sections[1].id] }
    let(:filters) { {} }
    include_context 'Section Progress Report'

    subject { Unit.for_standards_progress_report(teacher, filters).to_a }

    it 'can retrieve units based on no additional parameters' do
      expect(subject.size).to eq(units.size)
    end

    context 'sections' do
      let(:filters) { {section_id: section_ids} }

      it 'can retrieve units based on sections' do
        expect(subject.size).to eq(2) # 1 unit created for each section
      end
    end

    context 'students' do
      let(:filters) { {student_id: students.first.id} }

      it 'can retrieve units based on student_id' do
        expect(subject.size).to eq(1)
      end
    end

    context 'classrooms' do
      let(:filters) { {classroom_id: classrooms.first.id} }

      it 'can retrieve units based on classroom_id' do
        expect(subject.size).to eq(1)
      end
    end
  end

  describe '#update_unit and its helper methods' do
    let!(:activity1) {FactoryGirl.create(:activity)}
    let!(:activity2) {FactoryGirl.create(:activity)}

    let!(:classroom1) {FactoryGirl.create(:classroom)}
    let!(:student1) {FactoryGirl.create(:student, classcode: classroom1.code)}

    let!(:classroom2) {FactoryGirl.create(:classroom)}
    let!(:student2_1) {FactoryGirl.create(:student, classcode: classroom2.code)}
    let!(:student2_2) {FactoryGirl.create(:student, classcode: classroom2.code)}
    let!(:student2_3) {FactoryGirl.create(:student, classcode: classroom2.code)}

    let!(:ca1) {FactoryGirl.create(:classroom_activity,
                                    activity: activity1,
                                    classroom: classroom1, due_date: Date.today)}


    let!(:ca2) {FactoryGirl.create(:classroom_activity,
                                    activity: activity1,
                                    classroom: classroom2, due_date: Date.today,
                                    assigned_student_ids: [student2_1.id, student2_2.id])}

    let!(:ca3) {FactoryGirl.create(:classroom_activity,
                                    activity: activity2,
                                    classroom: classroom1, due_date: Date.today)}

    let!(:ca4) {FactoryGirl.create(:classroom_activity,
                                    activity: activity2,
                                    classroom: classroom2, due_date: Date.today,
                                    assigned_student_ids: [student2_1.id, student2_2.id])}

    let!(:unit1) {FactoryGirl.create(:unit, classroom_activities: [ca1, ca2, ca3, ca4])}

    let!(:activity3) {FactoryGirl.create(:activity)}
    let!(:classroom3) {FactoryGirl.create(:classroom)}
    let!(:student3) {FactoryGirl.create(:student, classcode: classroom3.code)}

    let!(:incoming_c2) {{id: classroom2.id, student_ids: [student2_2.id, student2_3.id]}}
    let!(:incoming_c3) {{id: classroom3.id, student_ids: []}}

    let!(:incoming_a2) {{id: activity2.id, due_date: Date.tomorrow}}
    let!(:incoming_a3) {{id: activity3.id, due_date: Date.tomorrow}}

    let!(:incoming_cs) {[incoming_c2, incoming_c3]}
    let!(:incoming_as) {[incoming_a2, incoming_a3]}

    describe '#helper methods' do
      describe '#split_extant_cas' do
        # split into to_be_updated, to_be_destroyed
        let!(:the_split) {unit1.split_extant_cas(incoming_cs, incoming_as)}
        let!(:extant_cas_to_be_updated) {the_split[0]}
        let!(:extant_cas_to_be_destroyed) {the_split[1]}

        it 'correctly identifies those to be updated' do
          expect(extant_cas_to_be_updated).to match_array([ca4])
        end

        it 'correctly identifies those which must perish' do
          expect(extant_cas_to_be_destroyed).to match_array([ca1, ca2, ca3])
        end

      end

      describe '#split_incoming' do
        # split incoming_cs into extant, new (and same for incoming_as)
        context "when splitting incoming_cs" do
          let!(:the_split) {unit1.split_incoming(incoming_cs, 'classroom_id')}
          let!(:extant) {the_split[0]}
          let!(:new) {the_split[1]}

          it "correctly identifies extant_incoming_cs" do
            expect(extant).to match_array([incoming_c2])
          end

          it "correctly identifies new_incoming_cs" do
            expect(new).to match_array([incoming_c3])
          end
        end

        context "when splitting incoming_as" do
          let!(:the_split) {unit1.split_incoming(incoming_as, 'activity_id')}
          let!(:extant) {the_split[0]}
          let!(:new) {the_split[1]}

          it "correctly identifies extant_incoming_as" do
            expect(extant).to match_array([incoming_a2])
          end

          it "correctly identifies new_incoming_as" do
            expect(new).to match_array([incoming_a3])
          end
        end
      end
    end

    describe '#update_unit' do

      before do
        unit1.update_unit "unit2", incoming_cs, incoming_as
      end

      it "destroys ca1, ca2, ca3" do
        arr1 = [ca1, ca2, ca3].map(&:id)
        arr2 = ClassroomActivity.where(id: arr1)
        expect(arr2).to be_empty
      end

      it "destroys the activity_sessions which were associated to ca1, ca2, ca3" do
        arr = [ca1, ca2, ca3].map do |ca|
          ass = ActivitySession.where(user: ca.students, activity: ca.activity)
        end
        arr.flatten!
        expect(arr).to be_empty
      end

      it "updates ca4 due_date" do
        expect(ca4.reload.due_date).to eq(Date.tomorrow)
      end

      it "updates ca4 assigned_student_ids" do
        expect(ca4.assigned_student_ids).to match_array([student2_2, student2_3].map(&:id))
      end

      it "destroys activity_sessions corresponding to the students whose ids are no longer present in ca4.assigned_student_ids" do
        as = ActivitySession.find_by(user: student2_1, activity: ca4.activity)
        expect(as).to be_nil
      end

      it "creates activity_sessions corresponding to the students whose ids are newly present in ca4.assigned_student_ids" do
        as = ActivitySession.find_by(user: student2_3, activity: ca4.activity)
        expect(as).to be_present
      end

      context "new cas" do
        let(:ca5) {ClassroomActivity.find_by classroom_id: incoming_c2[:id], activity_id: incoming_a3[:id]}
        let(:ca6) {ClassroomActivity.find_by classroom_id: incoming_c3[:id], activity_id: incoming_a2[:id]}
        let(:ca7) {ClassroomActivity.find_by classroom_id: incoming_c3[:id], activity_id: incoming_a3[:id]}

        it "creates certain new cas" do
=begin
  create a new cas for each of the following
    incoming_c2 | incoming_a3
      student2_2, student2_3
    incoming_c3 | incoming_a2
      all_students
    incoming_c3 | incoming_a3
      all_students
=end
          expect([ca5, ca6, ca7]).to_not include(nil)
        end

        it "gives ca5 the appropriate assigned_student_ids" do
          arr = [
                  [student2_2.id, student2_3.id],
                  [],
                  [],
                ]
          arr2 = []
          [ca5, ca6, ca7].each_with_index do |ca, i|
            x = (ca.assigned_student_ids == arr[i])
            arr2.push x
          end
          expect(arr2).to_not include(false)
        end

        it "creates the appropriate activity_sessions for the new cas" do

        end
      end
    end
  end
end