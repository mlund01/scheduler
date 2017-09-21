class Api::V1::UsersController < ApplicationController

	before_action :set_user, :only => [:show]

	def index
		query = User.all
		query = limit_by_employees_working_overlapping_shifts(query)
		render json: query, status: :ok
	end

	def show
		render json: @user, status: :ok
	end

	private

	def set_user
		@user = policy_scope(User).find(params[:id])
	end

	def limit_by_employees_working_overlapping_shifts(query)
		if params[:shift_start].present? and params[:shift_end].present?
			query = query.with_shift_in_time_range(params[:shift_start], params[:shift_end])
			return query
		else
			return query
		end
	end

end
