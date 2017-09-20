class Api::V1::ShiftsController < ApplicationController

	before_action :set_shift, :only => [:update]

	def index
		query = policy_scope(Shift)
		query = limit_by_assignment_type(query)
		query = limit_by_range(query)
		render json: query, status: :ok
	end

	def create
		shift = Shift.new(shift_params)
		shift.manager_id = current_user.id unless shift.manager_id.present?
		authorize shift
		if shift.save
			render json: shift, status: :ok
		else
			render json: { errors: shift.errors }, status: :bad_request
		end
	end

	def update
		authorize @shift
		if @shift.update(shift_update_params)
			render json: @shift, status: :ok
		else
			render json: { errors: @shift.errors }, status: :bad_request
		end
	end

	private

	def shift_params
		params.permit(:employee_id, :manager_id, :start_time, :end_time)
	end

	def shift_update_params
		params.permit(:employee_id, :start_time, :end_time)
	end

	def set_shift
		@shift = Shift.find(params[:id])
	end

	def limit_by_assignment_type(query)
		query = query.assigned_to(current_user.id) if params[:scope] == "assigned"
		query = query.unassigned if params[:scope] == "unassigned"
		return query
	end

	def limit_by_range(query)
		query = query.limit_by_time_range(Time.parse(params[:start]), Time.parse(params[:end])) if params[:start].present? and params[:end].present?
		return query
	end


end
