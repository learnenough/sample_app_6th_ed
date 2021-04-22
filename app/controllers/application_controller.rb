class ApplicationController < ActionController::Base
  include SessionsHelper
  
  rescue_from LoginError, with: :on_login_error
  
  skip_before_action :verify_authenticity_token, 
    if: Proc.new { ENV['SWAGGER'] == 'true' }

  protected
  
  def on_login_error(err)
    render json: { error: { message: err.message } }, status: 401
  end

  private

  include LoggedInHelper
end
