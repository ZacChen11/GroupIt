class SessionsController < ApplicationController
  before_action :logged_in_user, only: [:create, :new]

  private def logged_in_user
    if current_user
      flash.notice = "You have already logged in"
      redirect_to current_user
    end
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if  user && user.authenticate(params[:session][:password])
      if user.activated
        # places a temporary cookie on the user’s browser containing an encrypted version of the user’s id,
        # which allows to retrieve the id on subsequent pages using session[:user_id]
        log_in(user)
        redirect_to user
      else
        flash.notice = "The User Account is not activated !!"
        redirect_to root_path
      end
    else
      flash.notice = "Incorrect email address or password !!"
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_path
  end

  def welcome
  end

end
