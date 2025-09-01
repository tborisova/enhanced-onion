class UploadsController < ApplicationController
  before_action :authenticate_user!

  def create
    @form = UploadForm.new image: params[:upload_form][:image]

    @form.execute
  end

  def upload
    r = TemporaryRecipeImage.create!

    r.image.attach(io: params[:file], filename: params[:file].original_filename)

    render json: { id: r.id }
  end

  def show
    @recipe = TemporaryRecipeImage.find params[:id]
  end

  def new
    @form = UploadForm.new image: nil
  end
end
