namespace :cleanup do
  desc "Delete temporary recipe images older than 24 hours"
  task temporary_images: :environment do
    old_images = TemporaryRecipeImage.where("created_at < ?", 24.hours.ago)
    count = old_images.count
    old_images.destroy_all
    puts "Deleted #{count} temporary recipe images"
  end
end
