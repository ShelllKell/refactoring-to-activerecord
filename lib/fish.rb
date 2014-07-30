require "active_record"

class Fish < ActiveRecord::Base
  belongs_to :user
end