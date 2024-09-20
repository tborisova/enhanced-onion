class UploadForm
  include ActiveModel::Model

  attr_accessor :image

  def initialize(image:)
    @image = image
  end

  def execute
    r = TemporaryRecipeImage.create!
    r.image.attach(@image)

    r
  end
end
