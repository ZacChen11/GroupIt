module SessionsHelper

  # places a temporary cookie on the user’s browser containing an encrypted version of the user’s id,
  # which allows to retrieve the id on subsequent pages using session[:user_id]
  def log_in(user)
    session[:user_id] = user.id
  end

  # find the user in the database corresponding to the session id
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  #
  # def host_id(user)
  #   @host_user ||= User.find_by(id: user.id)
  # end
  #
  # def wipe_host_user
  #   @host_user = nil
  # end

end
