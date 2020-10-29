# frozen_string_literal: true

class SalePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end    
  end
end
