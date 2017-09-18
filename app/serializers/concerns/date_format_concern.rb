module DateFormatConcern
	extend ActiveSupport::Concern

	included do
		def created_at
			object.created_at.rfc2822
		end

		def updated_at
			object.updated_at.rfc2822
		end
	end
end