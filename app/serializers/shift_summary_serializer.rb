class ShiftSummarySerializer < ActiveModel::Serializer
	attributes :week_beginning, :hours

	def week_beginning
		object.week_beginning.rfc2822
	end

	def hours
		object.hours.round(2)
	end
end