class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user?

  before_filter :set_locale

  def set_locale
    session[:locale] ||= params[:locale]
    I18n.locale = session[:locale]
  end
  
  private 
  
  def current_user?
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
