class Carpark < ActiveRecord::Base
  belongs_to :garage
  belongs_to :user
  has_many :photos, as: :photoble
  has_many :rents, :dependent => :destroy, :inverse_of => :carpark
  has_many :bookings, :dependent => :destroy, :inverse_of => :carpark

  accepts_nested_attributes_for :rents, allow_destroy: true
  accepts_nested_attributes_for :bookings, :allow_destroy => true

  validates_uniqueness_of :number, :scope => :garage_id
  validates :number, :profit, :price, :reduced_price, :garage, :user, presence: true
  validates_numericality_of :number, :profit, :price, :reduced_price

  def get_availabilities
     Availability.joins(rent: :carpark).where('carparks.id = ?', self.id)
  end

  def get_booking_times
    BookingTime.joins(booking: :carpark).where('carparks.id = ?', self.id)
  end

end