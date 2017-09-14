class ShiftSerializer < ActiveModel::Serializer
	include DateFormatConcern
	attributes :id, :manager_id, :employee_id, :break, :start_time, :end_time, :created_at, :updated_at

	def start_time
		object.start_time.rfc28822
	end

	def end_time
		object.end_time.rfc28822
	end
	
end