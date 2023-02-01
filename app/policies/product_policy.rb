class ProductPolicy < ApplicationPolicy

  def show?
    true
  end

  def update?
    record.user == user
  end
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end
end
