# frozen_string_literal: true

class ContactPolicy < ApplicationPolicy
  class Scope < Struct.new(:contact, :scope)
    def resolve
      scope
    end
  end
end
