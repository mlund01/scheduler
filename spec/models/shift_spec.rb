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
	end

	context "associations" do
		it { should belong_to(:employee) }
		it { should belong_to(:manager) }
	end

	context "scopes" do
		it "should only return shifts assigned to employee with assigned_to" do
			employee_2 = create(:user, :role => :employee, :phone => '3332221111')
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id)
			create(:shift, :manager_id => @manager.id, :employee_id => @employee.id)
			create(:shift, :manager_id => @manager.id, :employee_id => employee_2.id)
			employee_shifts = Shift.assigned_to(@employee.id)
			expect(employee_shifts.count).to eq(2)
		end
	end
end