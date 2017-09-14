class User < ApplicationRecord
	validates_presence_of :name, :role
	validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Invalid email" }, allow_blank: true
	validates :phone, format: { with: /\A[0-9]{10}/, message: "Invalid Phone Number, must be 10 digits"}, allow_blank: true
	validate :validate_presence_of_phone_or_email

	before_validation :clean_phone_number

	enum role: [:employee, :manager]
	has_many :shifts, :foreign_key => :employee_id
	has_many :managed_shifts, :class_name => "Shift", :foreign_key => :manager_id

	private

	def validate_presence_of_phone_or_email
		errors.add(:base, "Phone or Email must be present") unless phone.present? or email.present?
	end

	def clean_phone_number
		if phone.present? and phone_changed?
			self.phone.gsub!(/[\s\-\(\)]/, '') if self.phone.gsub(/[\s\-\(\)]/, '')
		end
	end
end
