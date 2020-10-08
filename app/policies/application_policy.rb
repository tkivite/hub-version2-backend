# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def user_permissions
    # @user.roles.select(:permissions).distinct.map(&:permissions).flatten
    @user.roles.select(:permissions).distinct.map(&:permissions).flatten
  end

  def inferred_activity(method)
    # p "#{@record.class.name.downcase}:#{method}"
    "#{@record.class.name.downcase}:#{method}"
  end

  def method_missing(name, *args)
    if name.to_s.last == '?'
      user_permissions.include?(inferred_activity(name.to_s.gsub('?', '')))
    else
      super
    end
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end
end
