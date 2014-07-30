require "active_record"

class User < ActiveRecord::Base
  has_one :fish

  validates :username, :presence => {message: "Username is required"}, :uniqueness => {message: "Username has already been taken"}
  validates :password, :presence => {message: "Password is required"}, :length => {:minimum => 4, message: "Password must be at least 4 characters"}
end