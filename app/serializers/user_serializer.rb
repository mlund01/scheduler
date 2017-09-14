class UserSerializer < ActiveModel::Serializer
	include DateFormatConcern
	attributes :id, :name, :role, :email, :phone, :created_at, :updated_at
end