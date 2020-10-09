# frozen_string_literal: true

class RolesController < ApplicationController
  before_action :set_role, only: %i[show update destroy]
  # GET /roles
  def index
    @roles = Role.all
    authorize @roles.first, :list?
    policy_scope @roles
    json_response(@roles, :ok)
  end

  # POST /roles
  def create
    @role = Role.new(role_params)
    authorize @role, :create?
    return json_response(@role, :unprocessable_entity) unless @role.save

    json_response(@role, :created)
  end

  # GET /roles/:id
  def show
    authorize @role, :view?
    json_response(@role)
  end

  # PUT /roles/:id
  def update
    authorize @role, :update?
    @role.update!(role_params)
    json_response(@role)
  end

  # DELETE /roles/:id
  def destroy
    authorize @role, :destroy?
    @role.destroy
    json_response(@roles)
  end

  private

  def role_params
    # whitelist params
    params.permit(:id, :name, :role_type, :rank, :created_by, permissions: [])
  end

  def set_role
    @role = Role.find(params[:id])
  end
end
