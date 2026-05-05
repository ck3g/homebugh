module Api
  module V1
    class SyncController < BaseController
      def create
        result = Api::SyncService.new(current_user).call(
          last_synced_at: params[:last_synced_at],
          changes: params[:changes]&.to_unsafe_h || {}
        )

        render json: {
          pushed: result[:pushed],
          pull: result[:pull]
        }
      end
    end
  end
end
