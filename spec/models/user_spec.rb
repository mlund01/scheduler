require 'rails_helper'

RSpec.describe User, type: :model do
	context "validations" do
		it { should validate_presence_of(:name) }
		it { should validate_presence_of(:role) }
		it { should allow_value("test@mail.com").for(:email) }
		it { should_not allow_value("not-an_email").for(:email) }
		it { should allow_value("1233211234").for(:phone) }
		it { should_not allow_value("123321").for(:phone) }
		it { should_not allow_value("tenletters").for(:phone) }
		it { should_not allow_value("tenLet1232").for(:phone) }
		it "should raise error without presence of phone or email" do
			expect{create(:user, :role => :employee, :email => nil, :phone => nil)}.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Phone or Email must be present")
		end
		it "should validate presence of phone or email" do
			expect{create(:user, :role => :employee, :phone => "1233211234")}.to_not raise_error
			expect{create(:user, :role => :employee, :email => "test@test.com")}.to_not raise_error
		end
		it "should remove white space and delimiters of phone number before validation" do
			user = create(:user, :role => :employee, :phone => "(123) 342-1221")
			expect(user.phone).to eq("1233421221")
		end
	end

	context "associations" do
		it { should have_many(:shifts) }
		it { should have_many(:managed_shifts) }
	end

	context "enums" do
		it { should define_enum_for(:role).with(:employee => 0, :manager => 1) }
	end

	context "scopes" do
		it "should find a user by their phone or email when using find_by_phone_or_email" do
			user_1 = create(:user, :role => :employee)
			user_2 = create(:user, :role => :employee, :phone => "1233211234")
			expect(User.find_by_phone_or_email(user_1.email).count).to eq(1)
			expect(User.find_by_phone_or_email(user_2.phone).count).to eq(1)
		end
		it "should find users who have an assigned shift in the given time range using with_shift_in_time_range" do
			manager = create(:user, :role => :manager)
			user_1 = create(:user, :role => :employee)
			user_2 = create(:user, :role => :employee)
			user_2 = create(:user, :role => :employee)
			t = Time.new
			create(:shift, :employee_id => user_1.id, :manager_id => manager.id, :start_time => t + 1.hour, :end_time => t + 4.hours)
			create(:shift, :employee_id => user_2.id, :manager_id => manager.id, :start_time => t + 5.hours, :end_time => t + 8.hours)
			create(:shift, :employee_id => user_1.id, :manager_id => manager.id, :start_time => t + 2.hours, :end_time => t + 6.hours)
			expect(User.with_shift_in_time_range((t + 2.hours).to_s, (t + 4.hours).to_s).count).to eq(2)
		end
	end
	
end