module DateFormatConcern
	extend ActiveSupport::Concern

	included do
		def created_at
			object.created_at.rfc28822
		end

		def updated_at
			object.updated_at.rfc28822
		end
	end
end