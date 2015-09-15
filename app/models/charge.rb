class Charge < ActiveRecord::Base
  belongs_to :booking_time

  validates_presence_of :booking_time, :paid_at

end
