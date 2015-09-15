class BookingTime < ActiveRecord::Base
  include TimeSpan

  acts_as_time_span :minimum_minutes_duration => 60

  belongs_to :booking

  #validates_associated :booking
  validates_presence_of :start_time, :end_time, :booking
  validate :validate_exist_availability
  validate :validate_overlaps

  before_destroy :ensure_is_not_paid

  scope :not_paid, -> { where(paid: false) }
  scope :already_paid, -> { where(paid: true) }
  scope :not_id, ->(id) { where(['booking_times.id <> ?',id.to_i]) }

  scope :next, -> { where(['booking_times.start_time > ?', DateTime.now]).order('booking_times.start_time ASC') }

  def exist_availability?
    if booking.nil?
      return false
    end
    # si queremos dejar minutos al principio y al final de la disponibilidad
    booking.carpark.get_availabilities.starts_before(start_time - MINIMUN_MINUTES_SEGMENT.minutes)
        .ends_after(fixed_end_time + MINIMUN_MINUTES_SEGMENT.minutes).count == 1
    #booking.carpark.get_availabilities.starts_before(start_time).ends_after(fixed_end_time).count == 1
  end

  def validate_exist_availability
    errors.add(:availability, I18n.t('activerecord.errors.models.booking_time.not_availabitity')) unless exist_availability?
  end

  def start_overlap?
    !booking.carpark.get_booking_times.in_same_day(start_time).not_id(id).
        starts_before(start_time).
        ends_after(start_time).count.zero?
  end

  def end_overlap?
    !booking.carpark.get_booking_times.in_same_day(start_time).not_id(id).
        starts_before(fixed_end_time).
        ends_after(fixed_end_time).count.zero?
  end

  def inner_overlap?
    !booking.carpark.get_booking_times.in_same_day(start_time).not_id(id).
        starts_before(start_time).
        ends_after(fixed_end_time).count.zero?
  end

  def wrapper_overlap?
    !booking.carpark.get_booking_times.in_same_day(start_time).not_id(id).
        starts_after(start_time - MINIMUN_MINUTES_SEGMENT.minutes).
        ends_before(fixed_end_time).count.zero?
  end

  def overlap?
    start_overlap? || end_overlap? || inner_overlap? || wrapper_overlap?
  end

  def total_amount
    duration = duration_in_hours
    if (duration  <= 4)
      duration * booking.price
    else
      duration * booking.reduced_price
    end
  end

  def total_profit
    duration_in_hours * booking.carpark.profit
  end

  protected

  def validate_overlaps
    errors.add(:start_overlap, I18n.t('activerecord.errors.models.booking_time.start_overlap')) if start_overlap?
    errors.add(:end_overlap, I18n.t('activerecord.errors.models.booking_time.end_overlap')) if end_overlap?
    errors.add(:inner_overlap, I18n.t('activerecord.errors.models.booking_time.inner_overlap')) if inner_overlap?
    errors.add(:wrapper_overlap, I18n.t('activerecord.errors.models.booking_time.wrapper_overlap')) if wrapper_overlap?
  end

  def ensure_is_not_paid
    if self.paid?
      errors[:destroy] << I18n.t('activerecord.errors.models.booking_time.already_paid')
      return false
    end
  end

end
