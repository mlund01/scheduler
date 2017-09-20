class ShiftPolicy < ApplicationPolicy
	def update?
		user.manager?
	end

	def create?
		user.manager?
	end

	class Scope < Scope
		def resolve
			if user.manager?
				scope.all
			else
				scope.assigned_to(user.id).or(scope.unassigned)
			end
		end
	end
end