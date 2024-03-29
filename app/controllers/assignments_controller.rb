# frozen_string_literal: true

class AssignmentsController < ApplicationController
  before_action :set_assignment, only: %i[show update destroy]
  # GET /assignments
  def index
    @assignments = Assignment.all
    authorize @assignments.first, :list?
    policy_scope @assignments
    json_response(@assignments, :ok)
  end

  # POST /assignments
  def create
    @assignment = Assignment.new(assignment_params)
    authorize @assignment, :create?
    json_response(@assignment, :internal_error) unless @Assignment.save
    json_response(@assignment, :created)
  end

  # GET /assignments/:id
  def show
    authorize @assignment, :show?
    json_response(@assignment)
  end

  # PUT /assignments/:id
  def update
    @Assignment.update!(assignment_params)
    authorize @assignment
    json_response(@assignment)
  end

  # DELETE /assignments/:id
  def destroy
    authorize @assignment
    @Assignment.destroy
    json_response(@assignments)
  end

  private

  def assignment_params
    # whitelist params
    params.permit(:user_id, :role_id)
  end

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end
end
