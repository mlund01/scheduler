class Api::V1::UsersController < ApplicationController

	before_action :set_user, :only => [:show]

	def index
		users = User.all
		render json: users, status: :ok
	end

	def show
		render json: @user, status: :ok
	end

	private

	def set_user
		@user = User.find(params[:id])
	end

end
