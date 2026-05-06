module Api
  module V1
    class CategoriesController < BaseController
      def index
        categories = current_user.categories
                      .updated_since(params[:updated_since])
                      .page(params[:page]).per(per_page)

        render json: {
          categories: CategoryBlueprint.render_as_hash(categories),
          meta: pagination_meta(categories)
        }
      end

      def show
        category = current_user.categories.find_by(id: params[:id])
        return render_not_found unless category

        render json: CategoryBlueprint.render_as_hash(category)
      end

      def create
        category = current_user.categories.new(create_params)

        if category.save
          render json: CategoryBlueprint.render_as_hash(category), status: :created
        else
          render_validation_errors(category)
        end
      end

      def update
        category = current_user.categories.find_by(id: params[:id])
        return render_not_found unless category

        if category.update(update_params)
          render json: CategoryBlueprint.render_as_hash(category)
        else
          render_validation_errors(category)
        end
      end

      def destroy
        category = current_user.categories.find_by(id: params[:id])
        return render_not_found unless category

        category.destroy
        if category.errors.any?
          render_validation_errors(category)
        else
          render json: { status: 'ok' }
        end
      end

      private

      def create_params
        params.permit(:name, :category_type_id, :inactive, :client_uuid)
      end

      def update_params
        params.permit(:name, :inactive)
      end
    end
  end
end
