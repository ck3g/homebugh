class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user?

  rescue_from CanCan::AccessDenied do |exception|
    path = user_signed_in? ? root_path : new_user_session_path
    redirect_to path, alert: exception.message
  end

  before_action :set_locale
  before_action :instantiate_controller_and_action_names

  def set_locale
    session[:locale] = params[:locale] if params[:locale].present?
    session[:locale] ||= I18n.default_locale
    I18n.locale = session[:locale]
  end

  protected

  def instantiate_controller_and_action_names
    @controller_name = controller_name
    @action_name = action_name
  end
end
