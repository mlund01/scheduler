require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
	let (:employee) { create(:user, :role => "employee") }
	let (:manager) { create(:user, :role => "manager")}
	let (:json) { JSON.parse(response.body) }	

	context "index" do
		it "should require authentication/valid auth" do
			get :index
			expect(response).to be_unauthorized
			set_invalid_auth
			get :index
			expect(response).to be_unauthorized
			set_valid_auth(manager.email, "johndoe123")
			get :index
			expect(response).to be_ok
		end
		
	end
	before(:each) do
		set_valid_auth(employee.email, "johndoe123")
		@em_2 = create(:user, :role => "employee")
		@em_3 = create(:user, :role => "employee")
		@em_4 = create(:user, :role => "employee")
		@man_2 = create(:user, :role => "manager")
		@man_3 = create(:user, :role => "manager")
		
	end
	context "index as employee" do
		
		it "should allow me to list users working the same time as me when providing the shift_start and shift_end" do
			t = Time.zone.now
			my_shift = create(:shift, :manager_id => manager.id, :employee_id => employee.id, :start_time => t + 4.hours, :end_time => t + 7.hours)
			create(:shift, :manager_id => manager.id, :employee_id => @em_2.id, :start_time => t + 5.hours, :end_time => t + 7.hours)
			create(:shift, :manager_id => manager.id, :employee_id => @em_3.id, :start_time => t + 8.hours, :end_time => t + 12.hours)
			create(:shift, :manager_id => manager.id, :employee_id => @em_4.id, :start_time => t + 9.hours, :end_time => t + 12.hours)
			get :index, params: { shift_start: my_shift.start_time, shift_end: my_shift.end_time }
			expect(json.length).to eq(2)
		end

	end

	context "index as manager" do
		before(:each) do
			set_valid_auth(manager.email, "johndoe123")
		end
		it "should allow me to list everyone" do
			get :index
			expect(response).to be_ok
			expect(json.length).to eq(7)
		end
	end

	context "show as employee" do
		it "should only allow me to get the details of managers" do
			get :show, params: { id: manager.id }
			expect(response).to be_ok
			get :show, params: { id: @em_2.id }
			expect(response).to be_not_found
		end
		it "should not allow me to get my own details" do
			get :show, params: {id: employee.id }
			expect(response).to be_ok
		end
	end

	context "show as manager" do
		before(:each) do
			set_valid_auth(manager.email, "johndoe123")
		end
		it "should allow me to get an employee" do
			get :show, params: { :id => employee.id }
			expect(response).to be_ok
		end
		it "should allow me to get another manager" do
			manager_2 = create(:user, :role => :manager)
			get :show, params: { :id => manager_2.id }
			expect(response).to be_ok
		end
	end
end
