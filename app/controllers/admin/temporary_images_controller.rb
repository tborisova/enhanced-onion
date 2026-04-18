module Admin
  class TemporaryImagesController < BaseController
    def index
      @pagy, @temporary_images = pagy(:offset, TemporaryRecipeImage.order(created_at: :desc).includes(:user), limit: 25)
    end

    def destroy
      @temporary_image = TemporaryRecipeImage.find(params[:id])
      @temporary_image.destroy
      redirect_to admin_temporary_images_path, notice: 'Temporary image deleted.'
    end
  end
end
