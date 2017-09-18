class ShiftSerializer < ActiveModel::Serializer
	include Rails.application.routes.url_helpers
	include DateFormatConcern
	attributes :id, :manager_id, :employee_id, :break, :start_time, :end_time, :created_at, :updated_at

	attribute :links do
		employee_id = object.employee_id
		manager_id = object.manager_id
		{
			employee: (api_v1_user_path(employee_id) unless employee_id.nil?),
			manager: api_v1_user_path(manager_id)
		}
	end

	def start_time
		object.start_time.rfc2822
	end

	def end_time
		object.end_time.rfc2822
	end
	
end