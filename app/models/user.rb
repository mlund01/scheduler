class User < ApplicationRecord
	attr_accessor :password

	validates_presence_of :name, :role
	validates_presence_of :password, :on => [:create]
	validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "Invalid email" }, allow_blank: true, uniqueness: true
	validates :phone, format: { with: /\A[0-9]{10}/, message: "Invalid Phone Number, must be 10 digits, numeric only"}, allow_blank: true, uniqueness: true
	validate :validate_presence_of_phone_or_email

	enum role: [:employee, :manager]
	has_many :shifts, :foreign_key => :employee_id
	has_many :managed_shifts, :class_name => "Shift", :foreign_key => :manager_id

	scope :find_by_phone_or_email, -> (val) { where("phone=? OR email=?", val, val) }
	scope :with_shift_in_time_range, -> (low, high) { joins(:shifts).merge(Shift.limit_by_time_range(Time.parse(low), Time.parse(high))) }

	before_validation :clean_phone_number
	before_create :encrypt_password
	after_create :clear_password

	private

	def encrypt_password
		if password.present?
			self.salt = BCrypt::Engine.generate_salt
    	self.encrypted_password = BCrypt::Engine.hash_secret(password, salt)
    end
	end

	def clear_password
		self.password = nil
	end

	def validate_presence_of_phone_or_email
		errors.add(:base, "Phone or Email must be present") unless phone.present? or email.present?
	end

	def clean_phone_number
		if phone.present? and phone_changed?
			self.phone.gsub!(/[\s\-\(\)]/, '') if self.phone.gsub(/[\s\-\(\)]/, '')
		end
	end
end
