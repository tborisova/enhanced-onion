class UploadsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    @form = UploadForm.new image: params[:upload_form][:image]

    r = @form.execute
  end

  def upload
    r = TemporaryRecipeImage.create!

    r.image.attach(io: params[:file], filename: params[:file].original_filename)

    return render json: {id: r.id}
  end

  def show
    @recipe = TemporaryRecipeImage.find params[:id]

    p url_for(@recipe.image)
  end

  def new
    @form = UploadForm.new image: nil
  end
end
