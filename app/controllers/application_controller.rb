class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

  # find the user in the database corresponding to the session id
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in_user
    if !current_user
      flash.notice = "Please Log In"
      redirect_to root_path
    end
  end

end
