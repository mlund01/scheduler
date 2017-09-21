class Shift < ApplicationRecord
	default_scope { order(start_time: :asc) }

	validates_presence_of :start_time, :end_time, :manager_id
	validate :end_time_must_be_later_than_start_time
	validate :manager_id_is_set_to_user_with_manager_role

	belongs_to :manager, :class_name => "User"
	belongs_to :employee, :class_name => "User", optional: true

	scope :assigned_to, -> (id) { where(:employee_id => id) }
	scope :unassigned, -> { where(:employee_id => nil) }

	scope :limit_by_time_range, -> (low, high) { where("end_time >= ? AND start_time <= ?", low, high) }

	def self.group_hours_by_week(employee_id)
		unscoped.where("start_time <= ? AND employee_id=?", Time.now, employee_id).select("date_trunc('week', start_time::timestamptz AT TIME ZONE '" + Time.zone.name + "') AT TIME ZONE '" + Time.zone.name + "' as week, SUM((EXTRACT(EPOCH FROM (end_time - start_time)) / 60 / 60)) as total_hours").group("week").order("week desc")
	end

	private

	def end_time_must_be_later_than_start_time
		if start_time.to_i > end_time.to_i
			errors.add(:end_time, "must be set to a later time than start_time")
		end
	end

	def manager_id_is_set_to_user_with_manager_role
		if manager_id_changed? and manager_id.present? and !User.find_by_id(manager_id).manager?
			errors.add(:manager_id, "must be set to user with the manager role")
		end
	end
end
