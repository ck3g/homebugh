module Api
  module V1
    class BaseController < ActionController::API
      include Api::Authenticatable

      before_action :authenticate_token!
    end
  end
end
