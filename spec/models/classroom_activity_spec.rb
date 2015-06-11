require 'rails_helper'

describe ClassroomActivity, :type => :model do

  let!(:activity){ FactoryGirl.create(:activity) }
  let!(:student){ FactoryGirl.build(:student) }
  let!(:classroom_activity) { ClassroomActivity.create(activity_id: activity.id, classroom_id: student.classroom.id) }


  describe "#destroy" do
  	it 'should destroy associated activity_sessions' do
  		classroom_activity.destroy
  		expect(student.activity_sessions.count).to eq(0)
  	end
  end


  describe ".create_session" do
	  it "must create a new session for the given arguments" do
	  	expect(ClassroomActivity.create_session(activity, user: student)).to be_valid
	  end
  end

  context "when it has a due_date_string attribute" do

  	describe "#due_date_string=" do
	  	it "must have a due date setter" do
	  		expect(classroom_activity.due_date_string="03/02/2012").to eq("03/02/2012")
	  	end
	  	it "must throw an exception whn not valid input" do
	  		expect{classroom_activity.due_date_string="03-02-2012"}.to raise_error ArgumentError
	  	end
	end

	describe "#due_date_string" do
		before do
			classroom_activity.due_date_string="03/02/2012"
		end
		it "must have a getter" do
			expect(classroom_activity.due_date_string).to  eq("03/02/2012")
		end
	end

  end

  describe "session_for" do

  		let(:classroom) { FactoryGirl.create(:classroom, code: '101') }
  		let(:student){ classroom.students.create(first_name: 'John', last_name: 'Doe') }

    	before do
	      student.generate_student
    	end

	  	it "must start a session for the given user" do
	  		expect(classroom_activity.session_for(student)).to be_valid
	  	end
	  	it "must raise an error when user's input is not valid" do
	  		expect{classroom_activity.session_for(0)}.to raise_error
	  	end
  end

  describe "#update_relevant_activity_sessions" do
    context "" do
      let!(:activity) {FactoryGirl.create(:activity)}
      let!(:classroom) {FactoryGirl.create(:classroom)}
      let!(:student1) {FactoryGirl.create(:student, classcode: classroom.code)}
      let!(:student2) {FactoryGirl.create(:student, classcode: classroom.code)}
      let!(:student3) {FactoryGirl.create(:student, classcode: classroom.code)}
      let!(:ca) {FactoryGirl.create(:classroom_activity,
                                     classroom: classroom,
                                     due_date: Date.today,
                                     activity: activity,
                                     assigned_student_ids: [student1.id, student2.id])}
      context "incoming student ids contains one extant student and one new student" do
        let!(:incoming_student_ids) {[student2.id, student3.id]}

        before do
          ca.update_relevant_activity_sessions(incoming_student_ids)
        end

        it "destroys activity session belonging to student1" do
          expect(ca.activity_sessions.find_by(user: student1)).to be_nil
        end

        it "does not destroy activity_session belonging to student2" do
          expect(ca.activity_sessions.find_by(user: student2)).to be_present
        end

        it "creates activity_session for student3" do
          expect(ca.activity_sessions.find_by(user: student3)).to be_present
        end
      end
    end

  end

end




































