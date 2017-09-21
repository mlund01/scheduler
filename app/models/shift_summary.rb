class ShiftSummary
	include ActiveModel::Serialization

	def initialize(hours, week_beginning)
		@hours = hours
		@week_beginning = week_beginning
	end
	attr_reader :hours
	attr_reader :week_beginning
end