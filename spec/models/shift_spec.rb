require 'rails_helper'

RSpec.describe Shift, type: :model do
	before(:each) do
		@employee = create(:user, :role => :employee, :phone => '1233211234')
		@manager = create(:user, :role => :manager, :phone => '3211233211')
	end
	context "validations" do
		it { should validate_presence_of(:start_time) }
		it { should validate_presence_of(:end_time) }
		it { should validate_presence_of(:manager_id) }
		it "should allow employee_id to be blank" do
			expect{create(:shift, :manager_id => @manager.id)}.to_not raise_error
		end
		it "should raise error if start_time is set later than end_time" do
			expect{
				create(:shift, 
					:manager_id => @manager.id,
					:start_time => Time.new + 1.day + 15.minutes,
					:end_time => Time.new + 1.day
					)
			}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: End time must be set to a later time than start_time")
		end
		it "should not allow manager_id to be from a user with user type of 'employee'" do
			user = create(:user, :role => "employee")
			expect{
				create(:shift, :manager_id => user.id, :start_time => Time.new, :end_time => Time.new + 5.hours)
				}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Manager must be set to user with the manager role")
		end
	end

	context "associations" do
		it { should belong_to(:employee) }
		it { should belong_to(:manager) }
	end

	context "scopes" do
		it "should only return shifts assigned to employee with assigned_to scope" do
			employee_2 = create(:user, :role => :employee, :phone => '3332221111')
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id)
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id)
			create(:shift, :manager_id => @manager.id, :employee_id => employee_2.id)
			employee_shifts = Shift.assigned_to(@employee.id)
			expect(employee_shifts.count).to eq(2)
		end

		it "should return unassigned shifts with unassigned scope" do
			create(:shift, :manager_id => @manager.id)
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id)
			create(:shift, :manager_id => @manager.id)
			employee_shifts = Shift.unassigned
			expect(employee_shifts.count).to eq(2)
		end

		it "should return any shift within date range with limit_by_time_range (inclusively)" do
			t = Time.new
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id, :start_time => t + 10.minutes, :end_time => t + 70.minutes)
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id, :start_time => t + 40.minutes, :end_time => t + 50.minutes)
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id, :start_time => t + 10.minutes, :end_time => t + 50.minutes)
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id, :start_time => t + 10.minutes, :end_time => t + 20.minutes)
			puts Shift.limit_by_time_range(t + 25.minutes, t + 45.minutes).as_json
			expect(Shift.limit_by_time_range(t + 25.minutes, t + 45.minutes).count).to eq(3)
			expect(Shift.limit_by_time_range(t, t + 5.minutes).count).to eq(0)
			expect(Shift.limit_by_time_range(t, t + 20.minutes).count).to eq(3)
			expect(Shift.limit_by_time_range(t + 60.minutes, t + 80.minutes).count).to eq(1)
			expect(Shift.limit_by_time_range(t, t + 80.minutes).count).to eq(4)
			expect(Shift.limit_by_time_range(t, t + 10.minutes).count).to eq(3)
			expect(Shift.limit_by_time_range(t + 70.minutes, t + 80.minutes).count).to eq(1)
		end
	end
end