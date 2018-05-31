class Notification < ActiveRecord::Base
  attr_accessible :value
  serialize :value, Hash
end
