# frozen_string_literal: true

class Api::ApiController < ActionController::Base
  skip_before_action :verify_authenticity_token

  # def render_error_msg(error_msg)
  #   render :json => {error: error_msg}
  # end
end
