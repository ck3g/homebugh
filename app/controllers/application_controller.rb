class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user?

  before_filter :set_locale
  before_filter :instantiate_controller_and_action_names

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

  def expire_statistics_cache
    expire_action controller: :statistics, action: :index
  end
end
