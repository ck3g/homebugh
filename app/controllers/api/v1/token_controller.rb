module Api
  module V1
    class TokenController < BaseController
      skip_before_action :authenticate_token!, only: [:create]

      def create
        user = User.find_by(email: params[:email])

        if user && !user.confirmed_at.present?
          return render json: { error: 'User not confirmed' }, status: :unauthorized
        end

        session = Api::TokenService.authenticate(params[:email], params[:password])

        if session
          render json: { token: session.token, user_id: session.user_id }, status: :created
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      def destroy
        token = extract_token_from_header
        Api::TokenService.revoke(token)

        render json: { status: 'ok' }
      end
    end
  end
end
