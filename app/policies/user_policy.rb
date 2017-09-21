class UserPolicy < ApplicationPolicy
	def index?
		true
	end

	def show?
		true
	end

	class Scope < Scope
		def resolve
			if user.manager?
				scope.all
			else
				scope.where(:role => :manager).or(scope.where(:id => user.id))
			end
		end
	end

end