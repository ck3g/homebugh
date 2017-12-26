module Api
  class TokenController < ApplicationController
    def create
      render json: { token: "123", result: "OK" }, status: :created
    end
  end
end
