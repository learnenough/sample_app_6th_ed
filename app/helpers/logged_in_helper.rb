module LoggedInHelper
  # @label security.require_login authentication
  def logged_in_api_user
    raise LoginError unless logged_in?
    true
  end

  # Confirms a logged-in user.
  # @label security.require_login authentication
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
