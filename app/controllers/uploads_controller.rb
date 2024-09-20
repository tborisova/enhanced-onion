class UploadsController < ApplicationController
  def create
    @form = UploadForm.new image: params[:upload_form][:image]

    r = @form.execute

    redirect_to upload_path(id: r.id)
  end

  def show
    @recipe = TemporaryRecipeImage.find params[:id]

    p url_for(@recipe.image)
  end

  def new
    @form = UploadForm.new image: nil
  end
end
