module Api
  module Authenticatable
    extend ActiveSupport::Concern

    private

    def authenticate_token!
      token = extract_token_from_header
      return render_unauthorized unless token

      user = Api::TokenService.find_user_by_token(token)
      return render_unauthorized unless user

      @current_user = user
    end

    def current_user
      @current_user
    end

    def extract_token_from_header
      header = request.headers['Authorization']
      return unless header

      header.split(' ').last if header.start_with?('Bearer ')
    end

    def render_unauthorized
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end
