class Subscription < ActiveRecord::Base
  attr_accessible :body
  serialize :body, Hash
end
