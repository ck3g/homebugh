module Api
  class TokenController < ApplicationController
    def create
      user = User.find_by(email: safe_params[:email])
      if user && user.valid_password?(safe_params[:password])
        user.update_column :access_token, access_token
        render json: { token: access_token, result: "OK" },
          status: :created
      else
        render json: { result: "Error", message: "Invalid E-Mail or Password" },
          status: :unauthorized
      end
    end

    private

    def safe_params
      params.fetch(:user, {})
    end

    def access_token
      @access_token ||= generate_access_token
    end

    def generate_access_token
      begin
        token = SecureRandom.hex
      end while User.where(access_token: token).exists?

      token
    end
  end
end
