class School < ActiveRecord::Base
  validates :name, presence: true
  has_many :terms
  has_many :courses, :through => :terms
  default_scope { order('name') }
end
