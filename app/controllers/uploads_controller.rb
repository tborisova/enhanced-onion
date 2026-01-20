class UploadsController < ApplicationController
  before_action :authenticate_user!

  ALLOWED_CONTENT_TYPES = %w[image/jpeg image/png image/webp image/heic image/heif].freeze
  MAX_FILE_SIZE = 10.megabytes

  def create
    @form = UploadForm.new image: params[:upload_form][:image]

    @form.execute
  end

  def upload
    file = params[:file]

    unless file.present?
      return render json: { error: 'No file provided' }, status: :unprocessable_entity
    end

    unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      return render json: { error: 'Invalid file type. Allowed: JPEG, PNG, WebP, HEIC' }, status: :unprocessable_entity
    end

    if file.size > MAX_FILE_SIZE
      return render json: { error: 'File too large. Maximum size: 10MB' }, status: :unprocessable_entity
    end

    r = TemporaryRecipeImage.create!(user: @current_user)
    r.image.attach(io: file, filename: file.original_filename)

    render json: { id: r.id }
  end

  def show
    @recipe = @current_user.temporary_recipe_images.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Image not found' }, status: :not_found
  end

  def new
    @form = UploadForm.new image: nil
  end
end
