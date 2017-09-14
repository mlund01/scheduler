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
	end

	context "associations" do
		it { should belong_to(:employee) }
		it { should belong_to(:manager) }
	end
end