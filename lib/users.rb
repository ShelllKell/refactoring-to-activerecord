require "active_record"

class User < ActiveRecord::Base
  has_one :fish

  validates :username, :presence => true, :length => {:minimum => 4}, :uniqueness => true
  validates :password, :presence => true
end