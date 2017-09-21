class ShiftSummarySerializer < ActiveModel::Serializer
	attributes :week_beginning, :hours

	def week_beginning
		object.week_beginning.rfc2822
	end
end