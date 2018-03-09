class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :verify_user_logged_in_before_action

  # find the user in the database corresponding to the session id
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def verify_user_logged_in_before_action
    if !current_user
      flash.notice = "Please Log In"
      redirect_to login_path
    end
  end

end
