module Api
  module V1
    class SyncController < BaseController
      MAX_CHANGES_PER_REQUEST = 100

      def create
        changes = params[:changes]&.to_unsafe_h || {}

        if total_changes_count(changes) > MAX_CHANGES_PER_REQUEST
          return render json: { error: "Too many changes. Maximum #{MAX_CHANGES_PER_REQUEST} per request." },
                        status: :payload_too_large
        end

        result = Api::SyncService.new(current_user).call(
          last_synced_at: params[:last_synced_at],
          changes: changes
        )

        render json: {
          pushed: result[:pushed],
          pull: result[:pull]
        }
      end

      private

      def total_changes_count(changes)
        changes.sum do |_resource_type, operations|
          (operations['created']&.size || 0) +
            (operations['updated']&.size || 0) +
            (operations['deleted']&.size || 0)
        end
      end
    end
  end
end
