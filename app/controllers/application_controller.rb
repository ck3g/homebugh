class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user?

  before_filter :set_locale
  before_filter :instantiate_controller_and_action_names

  def set_locale
    session[:locale] ||= params[:locale]
    I18n.locale = session[:locale]
  end

  def render_404
    render :file => "#{::Rails.root.to_s}/public/404.html", :layout => false, :status => 404
  end

  private

  def instantiate_controller_and_action_names
    @controller_name = controller_name
    @action_name = action_name
  end

  def current_user?
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
