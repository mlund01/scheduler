class Api::V1::ShiftsController < ApplicationController

	before_action :set_shift, :only => [:update]

	def index
		shifts = Shift.all
		render json: shifts, status: :ok
	end

	def create
		shift = Shift.new(shift_params)
		if shift.save
			render json: shift, status: :ok
		else
			render json: { errors: shift.errors }, status: :bad_request
		end
	end

	def update
		if @shift.update(shift_params)
			render json: @shift, status: :ok
		else
			render json: { errors: @shift.errors }, status: :bad_request
		end
	end

	private

	def shift_params
		params.permit(:employee_id, :start_time, :end_time)
	end

	def set_shift
		@shift = Shift.find(params[:id])
	end

end
