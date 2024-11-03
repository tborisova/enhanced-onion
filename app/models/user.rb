class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable
  devise :lockable, :registerable, :validatable, :recoverable, :database_authenticatable
  has_many :recipes

  devise :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
end
