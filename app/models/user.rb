class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :lockable, :registerable, :validatable, :recoverable, :database_authenticatable
  has_many :recipes

  devise :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  class << self
    def find_for_apple(email, apple_idx)
      where(email:).or(where(apple_idx:)).first
    end
  end
end
