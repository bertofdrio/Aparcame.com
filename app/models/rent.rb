class Rent < ActiveRecord::Base
  belongs_to :carpark, inverse_of: :rents
  has_many :availabilities, :dependent => :restrict_with_error

  validates_uniqueness_of :name, :scope => :carpark_id, :message => I18n.translate('activerecord.errors.models.rent.should_be_unique_carpark')
  validates_presence_of :carpark

  accepts_nested_attributes_for :availabilities, allow_destroy: true

  before_destroy :ensure_has_not_availabilities

  def ensure_has_not_availabilities
    return true if availabilities.count == 0
    return false
  end

  def delete_availabilities_without_booking
    av = availabilities.eager_load(:rent => [:carpark => [:bookings => :booking_times]]).
        where('not (availabilities.start_time <= booking_times.start_time and availabilities.end_time >= booking_times.end_time) or booking_times.start_time is null')
    av.destroy_all

    availabilities.reload
  end
end
