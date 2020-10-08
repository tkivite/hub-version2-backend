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

    if @assignment.save
      json_response(@assignment, :created)
    else
      json_response(@assignment, :unprocessable_entity)
    end
  end

  # GET /assignments/:id
  def show
    authorize @assignment, :show?
    json_response(@assignment)
  end

  # PUT /assignments/:id
  def update
    @assignment.update(assignment_params)
    authorize @assignment
    json_response(@assignment)
  end

  # DELETE /assignments/:id
  def destroy
    authorize @assignment
    @assignment.destroy
    json_response(@assignments)
  end

  private

  def assignment_params
    # whitelist params
    params.permit(:id,:user_id, :role_id)
  end

  def set_assignment
    @assignment = Assignment.find(params[:id])
  end
end
