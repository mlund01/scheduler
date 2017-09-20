require 'rails_helper'

RSpec.describe Api::V1::ShiftsController, type: :controller do

	let (:employee) { create(:user, :role => "employee") }
	let (:manager) { create(:user, :role => "manager")}
	let (:json) { JSON.parse(response.body) }	

	context "index" do
		it "should require authentication/have valid auth" do
			get :index
			expect(response).to be_unauthorized
			set_invalid_auth
			get :index
			expect(response).to be_unauthorized
			set_valid_auth(employee.email, "johndoe123")
			get :index
			expect(response).to be_ok
		end
		it "should order by start_time descending" do
			set_valid_auth(employee.email, "johndoe123")
			shift_1 = create(:shift, :employee_id => employee.id, :manager_id => manager.id)
			shift_2 = create(:shift, :employee_id => employee.id, :manager_id => manager.id, :start_time => Time.new + 3.hours, :end_time => Time.new + 5.hours)
			shift_3 = create(:shift, :employee_id => employee.id, :manager_id => manager.id, :start_time => Time.new + 2.hours, :end_time => Time.new + 4.hours)
			get :index
			expect(json[0]["id"]).to eq(shift_1.id)
			expect(json[1]["id"]).to eq(shift_3.id)
			expect(json[2]["id"]).to eq(shift_2.id)
		end
		it "should allow any role to access this resource" do

		end
	end

	context "index as an employee" do
		before(:each) do
			set_valid_auth(employee.email, "johndoe123")
			employee_2 = create(:user, :role => "employee")
			create(:shift, :employee_id => employee.id, :manager_id => manager.id)
			create(:shift, :employee_id => employee.id, :manager_id => manager.id)
			create(:shift, :employee_id => employee_2.id, :manager_id => manager.id)
			create(:shift, :manager_id => manager.id)
		end
		it "should only returns shifts assigned to employee or unassigned by default" do
			#this also tests 'should not return other employees shifts'
			get :index
			expect(json.length).to eq(3)
		end
		it "should limit shifts listed by unassigned if scope param == 'unassigned'" do
			get :index, params: { scope: "unassigned" }
			expect(json.length).to eq(1)
		end
		it "should limit shifts listed by assignment to employee when scope param == 'assigned'" do
			get :index, params: { scope: "assigned" }
			expect(json.length).to eq(2)
		end
	end

	context "index as a manager" do
		before(:each) do
			set_valid_auth(manager.email, "johndoe123")
			employee_2 = create(:user, :role => "employee")
			create(:shift, :employee_id => employee.id, :manager_id => manager.id)
			create(:shift, :employee_id => employee.id, :manager_id => manager.id)
			create(:shift, :employee_id => employee_2.id, :manager_id => manager.id)
			create(:shift, :manager_id => manager.id)
		end

		it "should return all shifts by default" do
			get :index
			expect(json.length).to eq(4)
		end
		it "should only return shifts that fall within specific time range if start and end params are present" do
			t = Time.new
			employee_2 = create(:user, :role => "employee")
			create(:shift, :employee_id => employee.id, :manager_id => manager.id, :start_time => t + 10.days, :end_time => t + 10.days + 5.hours)
			create(:shift, :employee_id => employee.id, :manager_id => manager.id, :start_time => t + 11.days, :end_time => t + 11.days + 5.hours)
			create(:shift, :employee_id => employee_2.id, :manager_id => manager.id, :start_time => t + 12.days, :end_time => t + 12.days + 5.hours)
			create(:shift, :manager_id => manager.id, :start_time => t + 13.days, :end_time => t + 13.days + 5.hours)
			get :index, params: {start: t + 9.days, end: t + 13.days + 3.hours }
			expect(json.length).to eq(4)
		end
		it "should throw an error if start or end time is invalid datetime string" do
			get :index, params: {start: "invalid", end: "datetime"}
			expect(response).to be_bad_request
		end
	end

	context "create" do
		it "should require authentication/have valid auth" do
			post :create
			expect(response).to be_unauthorized
			set_invalid_auth
			post :create
			expect(response).to be_unauthorized
			set_valid_auth(manager.email, "johndoe123")
			post :create, params: { :start_time => Time.new, :end_time => Time.new + 2.hours }
			expect(response).to be_ok
		end
		it "should not be accessible to employees" do
			set_valid_auth(employee.email, "johndoe123")
			post :create
			expect(response).to be_unauthorized
		end
	end

	context "create as a manager" do
		before(:each) do
			set_valid_auth(manager.email, "johndoe123")
			@t = Time.new
			@shift_data = {
				:start_time => @t + 1.hour,
				:end_time => @t + 5.hours,
				:employee_id => employee.id
			}
			@pattern = {
				:id => Integer,
				:start_time => wildcard_matcher,
				:end_time => wildcard_matcher,
				:employee_id => employee.id,
				:manager_id => manager.id,
				:break => nil,
				:created_at => wildcard_matcher,
				:updated_at => wildcard_matcher,
				:links => {
					:employee => wildcard_matcher,
					:manager => wildcard_matcher
				}
			}
		end
		it "should be able to create a shift for any employee and return new shift resource" do
			post :create, params: @shift_data
			expect(Shift.all.count).to eq(1)
			expect(response.body).to match_json_expression(@pattern)

			employee_2 = create(:user, :role => "employee")
			@shift_data[:employee_id] = employee_2.id
			@pattern[:employee_id] = employee_2.id
			post :create, params: @shift_data
			expect(Shift.all.count).to eq(2)
			expect(response.body).to match_json_expression(@pattern)
		end

		it "should default manager_id to creating manager" do
			post :create, params: @shift_data
			expect(json["manager_id"]).to eq(manager.id)
		end

		it "should allow employee_id be left to nil" do
			@shift_data[:employee_id] = nil
			post :create, params: @shift_data
			expect(response).to be_ok
			expect(json["employee_id"]).to eq(nil)
		end

		it "should allow manager_id to be set" do
			manager_2 = create(:user, :role => "manager")
			@shift_data["manager_id"] = manager_2.id
			post :create, params: @shift_data
			expect(response).to be_ok
			expect(json["manager_id"]).to eq(manager_2.id)
		end

		it "should return dates in rfc2822 format for all dates" do
			post :create, params: @shift_data
			@shift = Shift.first
			created_at_rfc = @shift.created_at.rfc2822
			updated_at_rfc = @shift.updated_at.rfc2822
			start_time_rfc = @shift.start_time.rfc2822
			end_time_rfc = @shift.end_time.rfc2822
			expect(json["created_at"]).to eq(created_at_rfc)
			expect(json["updated_at"]).to eq(updated_at_rfc)
			expect(json["start_time"]).to eq(start_time_rfc)
			expect(json["end_time"]).to eq(end_time_rfc)
		end

	end

	context "update" do
		before(:each) do
			shift = create(:shift, :employee_id => employee.id, :manager_id => manager.id)
			@shift_data = shift.as_json
			
		end
		it "should require authentication/have valid auth" do

			put :update, params: @shift_data
			expect(response).to be_unauthorized
			set_invalid_auth
			put :update, params: @shift_data
			expect(response).to be_unauthorized
			set_valid_auth(manager.email, "johndoe123")
			put :update, params: @shift_data
			expect(response).to be_ok
		end
		it "should not be accessible to employees" do
			set_valid_auth(employee.email, "johndoe123")

			put :update, params: @shift_data
			expect(response).to be_unauthorized
		end
	end

	context "update as manager" do
		before(:each) do
			set_valid_auth(manager.email, "johndoe123")
			@shift = create(:shift, :employee_id => employee.id, :manager_id => manager.id)
			@shift_data = @shift.as_json
			@shift_data.delete "created_at"
			@shift_data.delete "updated_at"
		end
		it "should let me change the shift times" do
			t = Time.zone.now
			start_time = t + 40.days
			end_time = t + 40.days + 5.hours
			put :update, params: { :id => @shift.id, :start_time => start_time, :end_time => end_time }
			expect(response).to be_ok
			expect(json["start_time"]).to eq(start_time.rfc2822)
			expect(json["end_time"]).to eq(end_time.rfc2822)
		end
		it "should let me change the employee assigned to the shift" do
			employee_2 = create(:user, :role => "employee")
			put :update, params: { :id => @shift.id, :employee_id => employee_2.id }
			expect(response).to be_ok
			expect(json["employee_id"]).to eq(employee_2.id)
		end
		it "should not let me update the manager_id" do
			manager_2 = create(:user, :role => "manager")
			put :update, params: { :id => @shift.id, :manager_id => manager_2.id }
			expect(response).to be_ok
			expect(json["manager_id"]).to eq(manager.id)
		end
	end

end
