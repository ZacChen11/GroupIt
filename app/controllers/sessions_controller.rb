class SessionsController < ApplicationController
  skip_before_action :verify_user_logged_in_before_action, only: [:welcome, :create, :new]
  before_action :verify_user_already_logged_in_before_action, only: [:create, :new]

  def create
    # check if user uses use name or email to login in
    if validate_email_format(params[:email_or_username])
      user = User.find_by(email: params[:email_or_username].downcase)
    else
      user = User.where('lower(user_name) = ?', params[:email_or_username].downcase.delete(' \t\r\n')).first
    end

    if user && user.authenticate(params[:password])
      if user.activated
        log_in(user)
         return redirect_to user
      else
        flash.notice = "The User Account is not activated !!"
        return redirect_to login_path
      end
    end

    flash.now.notice = "Incorrect email address or password !!"
    return render 'new'

  end

  def destroy
    log_out
    redirect_to root_path
  end

  def welcome
  end

  def new
  end


  private
  def verify_user_already_logged_in_before_action
    if current_user
      flash.notice = "You have already logged in"
      redirect_to current_user
    end
  end

  def validate_email_format(email)
    email_format = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    email =~ email_format
  end

  # places a temporary cookie on the user’s browser containing an encrypted version of the user’s id,
  # which allows to retrieve the id on subsequent pages using session[:user_id]
  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end


end
