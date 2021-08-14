class Management < ApplicationRecord
  validates :name, presence: true, length: { maximum: 15 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, length: { maximum: 40 }, format: { with: VALID_EMAIL_REGEX }

  has_secure_password
  VALID_PASSWORD_REGEX = /\A(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)(?=.*?[\W_])[!-~]+\z/
  validates :password, presence: true, length: { minimum: 12, maximum: 32 }, format: { with: VALID_PASSWORD_REGEX }

  require "resolv"
  attr_accessor :ip

  def valid_ip?(ip)
    !!(ip =~ Regexp.union([Resolv::IPv4::Regex]))
  end

  def add_rule(ip)
    `aws ec2 authorize-security-group-ingress --group-id sg-0513c7d8bccfb4c15 --protocol tcp --port 22 --cidr #{ip}/32`
  end

end
