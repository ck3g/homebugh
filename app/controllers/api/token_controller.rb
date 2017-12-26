module Api
  class TokenController < ApplicationController
    def create
      user = User.find_by(email: safe_params[:email])
      if user && user.valid_password?(safe_params[:password])
        render json: { token: "123", result: "OK" },
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
  end
end
