module Api
  module V1
    class CategoryTypesController < BaseController
      def index
        category_types = CategoryType.all

        render json: {
          category_types: CategoryTypeBlueprint.render_as_hash(category_types)
        }
      end

      def show
        category_type = CategoryType.find_by(id: params[:id])
        return render_not_found unless category_type

        render json: CategoryTypeBlueprint.render_as_hash(category_type)
      end
    end
  end
end
