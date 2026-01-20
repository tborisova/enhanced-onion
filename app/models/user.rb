class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :lockable, :registerable, :validatable, :recoverable, :database_authenticatable
  has_many :recipes
  has_many :temporary_recipe_images
  belongs_to :plan

  devise :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  class << self
    def find_for_apple(email, apple_idx)
      where(email:).or(where(apple_idx:)).first
    end
  end

  def generate_login_token!
    self.login_token = SecureRandom.hex(16)
    self.login_token_sent_at = Time.current
    save!
  end

  def login_token_valid?
    login_token_sent_at && login_token_sent_at > 15.minutes.ago
  end

  def clear_login_token!
    update!(login_token: nil, login_token_sent_at: nil)
  end

  def plan_limits
    @plan_limits ||=
      if plan.is_free
        {
          free: true,
          recipes_quota_reached: false,
          images_quota_reached: false,
          remaining_images_count: nil,
          remaining_recipes_count: nil
        }
      else
        recipes_count = recipes.count
        images_count = recipes.joins(:photo_attachment).count

        {
          free: false,
          recipes_quota_reached: plan.recipes_quota < recipes_count,
          images_quota_reached: plan.images_quota < images_count,
          remaining_recipes_count: (plan.recipes_quota - recipes_count).clamp(0, Float::INFINITY),
          remaining_images_count: (plan.images_quota - images_count).clamp(0, Float::INFINITY)
        }
      end
  end
end
