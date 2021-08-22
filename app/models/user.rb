class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { maximum: 15 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, length: { maximum: 40 }, format: { with: VALID_EMAIL_REGEX }

  has_secure_password
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)(?=.*?[\W_])[!-~]+\z/
  validates :password, presence: true, length: { minimum: 12, maximum: 32 }, format: { with: VALID_PASSWORD_REGEX }
end
