class Shift < ApplicationRecord
	validates_presence_of :start_time, :end_time, :manager_id
	validate :end_time_must_be_later_than_start_time

	belongs_to :manager, :class_name => "User"
	belongs_to :employee, :class_name => "User", optional: true

	scope :assigned_to, -> (id) { where(:employee_id => id) }

	private

	def end_time_must_be_later_than_start_time
		if start_time.to_i > end_time.to_i
			errors.add(:end_time, "must be set to a later time than start_time")
		end
	end
end
