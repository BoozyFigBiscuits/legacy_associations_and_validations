class Reading < ActiveRecord::Base

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  belongs_to :lesson
  has_many :courses, :through => :lessons

  def clone
    dup
  end
end
