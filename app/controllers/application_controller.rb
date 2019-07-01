class ApplicationController < ActionController::Base
  
  helper_method :current_user

  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    else
      @current_user = nil
    end
  end

  def authenticate_user
    if session[:user_id] && session[:expiry_time]
      if session[:expiry_time] >= 12.hours.ago.to_s
        session[:expiry_time] = Time.current.to_s
      else
        session[:user_id] = nil
        # redirect
        redirect_to auth_path
      end
    else
      # redirect
      flash[:warning] = 'Please signin'
      redirect_to auth_path
    end
  end
end
