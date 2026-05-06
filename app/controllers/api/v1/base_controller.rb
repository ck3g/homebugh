module Api
  module V1
    class BaseController < ActionController::API
      include Api::Authenticatable

      DEFAULT_PER_PAGE = 20
      MAX_PER_PAGE = 50

      before_action :authenticate_token!

      rescue_from StandardError, with: :render_internal_error
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      private

      def per_page
        [[params.fetch(:per_page, DEFAULT_PER_PAGE).to_i, 1].max, MAX_PER_PAGE].min
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

      def render_validation_errors(record)
        render json: {
          error: 'Validation failed',
          details: record.errors.messages
        }, status: :unprocessable_entity
      end

      def render_internal_error(exception)
        Rails.logger.error("API Error: #{exception.message}")
        Rails.logger.error(exception.backtrace&.first(10)&.join("\n"))
        render json: { error: 'Internal server error' }, status: :internal_server_error
      end
    end
  end
end
