# frozen_string_literal: true

class StoreAccountPolicy < ApplicationPolicy
  class Scope < Struct.new(:store_account, :scope)
    def resolve
      scope
    end
  end
end
