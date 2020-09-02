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
    json_response(@role, :internal_error) unless @role.save
    json_response(@role, :created)
  end

  # GET /roles/:id
  def show
    json_response(@role)
  end

  # PUT /roles/:id
  def update
    @role.update!(role_params)
    json_response(@role)
  end

  # DELETE /roles/:id
  def destroy
    @role.destroy
    json_response(@roles)
  end

  private

  def role_params
    # whitelist params
    params.permit(:name, :role_type, :rank)
  end

  def set_role
    @role = Role.find(params[:id])
  end
end
