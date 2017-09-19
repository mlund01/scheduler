class ApplicationController < ActionController::API
	include ActionController::HttpAuthentication::Basic

	before_action :authenticate_and_set_current_user

	rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found

	private

	def record_not_found(e)
		render json: { error: e.message }, status: :not_found
	end

	def current_user
		@current_user
	end

	def authenticate_and_set_current_user
		creds = user_name_and_password(request)
		username = creds[0]
		password = creds[1]
		user = User.find_by_phone_or_email(username).first
		if user.present?
			user_password = BCrypt::Password.new(user.encrypted_password)
			if user_password == password
				@current_user = user
			else
				render json: { error: "Invalid credentials" }, status: :unauthorized
			end
		else
			render json: { error: "Invalid credentials" }, status: :unauthorized
		end
			
	end

end
