class Shift < ApplicationRecord
	validates_presence_of :start_time, :end_time, :manager_id

	belongs_to :manager, :class_name => "User"
	belongs_to :employee, :class_name => "User", optional: true
end
