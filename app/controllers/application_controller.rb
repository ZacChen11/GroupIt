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

  def is_admin_before_action
    if !current_user.has_role?("administrator")
      flash.notice = "You don't have the privilege"
      redirect_to root_path
    end
  end

  def verify_user_already_logged_in_before_action
    if current_user
      flash.notice = "You have already logged in"
      redirect_to root_path
    end
  end

  def set_record_to_deleted(record)
    record.update(deleted: true)
  end

end
