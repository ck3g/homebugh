class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user?

  before_filter :set_locale
  before_filter :instantiate_controller_and_action_names

  def set_locale
    I18n.locale = params[:locale] || I18n.locale || I18n.default_locale
  end

  private
  def instantiate_controller_and_action_names
    @controller_name = controller_name
    @action_name = action_name
  end
end
