class SessionsController < ApplicationController

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if  user && user.authenticate(params[:session][:password])
      # places a temporary cookie on the user’s browser containing an encrypted version of the user’s id,
      # which allows to retrieve the id on subsequent pages using session[:user_id]
      log_in user
      redirect_to user
    else
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to 'new'
  end

end
