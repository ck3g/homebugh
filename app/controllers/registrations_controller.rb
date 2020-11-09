class RegistrationsController < Devise::RegistrationsController
  def create
    if params.dig(:user, :name).present?
      # A hidden field filled in by a bot
      redirect_to new_user_registration_path, notice: "We're sorry. The registration is now closed."
      return
    end

    build_resource(sign_up_params)

    if verify_recaptcha(model: resource)
      resource.save
    end

    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    acc_params = resource.demo_user? ? {} : account_update_params

    resource_updated = update_resource(resource, acc_params)
    yield resource if block_given?
    if !resource.demo_user? && resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end
end
