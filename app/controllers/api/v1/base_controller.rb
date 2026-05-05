module Api
  module V1
    class BaseController < ActionController::API
      include Api::Authenticatable

      before_action :authenticate_token!

      private

      def per_page
        [params.fetch(:per_page, 20).to_i, 50].min
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          per_page: collection.limit_value,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end

      def render_not_found
        render json: { error: 'Not found' }, status: :not_found
      end
    end
  end
end
