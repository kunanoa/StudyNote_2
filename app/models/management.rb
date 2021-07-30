class Management < ApplicationRecord
  require "resolv"
  attr_accessor :ip

  def valid_ip?(ip)
    !!(ip =~ Regexp.union([Resolv::IPv4::Regex]))
  end

  def add_rule(ip)
    `aws ec2 authorize-security-group-ingress --group-id sg-0513c7d8bccfb4c15 --protocol tcp --port 22 --cidr #{ip}/32`
  end
end
