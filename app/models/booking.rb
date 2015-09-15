class Booking < ActiveRecord::Base

  belongs_to :carpark, inverse_of: :bookings
  belongs_to :user

  has_many :booking_times, :dependent => :restrict_with_error, :inverse_of => :booking
  accepts_nested_attributes_for :booking_times, :allow_destroy => true

  validates_presence_of :user, :carpark
  validate :validate_different_carpark_user, if: Proc.new { |booking| !booking.carpark.nil? && !booking.user.nil? }
  validate :validate_balance, if: Proc.new { |booking| !booking.user.nil? }
  validates :phone, format: { with: /\d{9}/i,
            message: I18n.t('activerecord.errors.models.booking.invalid') }, presence: true

  validates :license, format: {with: /(\d{4}-[\D\w]{3}|[\D\w]{1,2}-\d{4}-[\D\\w]{2})/i,
                               message: I18n.t('activerecord.errors.models.booking.invalid')}, presence: true


  before_validation :init_values
  before_destroy :ensure_has_not_booking_times
  before_update :ensure_has_not_booking_times_paid

  # scope :owner_by, ->(id) { where(['user_id = ?', id.to_i]) }


  def delete_booking_times_not_paid
    bt = booking_times.not_paid.destroy_all
    booking_times.reload
    return bt.length
  end

  def total_amount
    total_amount = BigDecimal(0.0, 2)
    self.booking_times.each { |booking_time| total_amount += booking_time.total_amount }
    total_amount
  end

  def can_edit?
    booking_times.already_paid.count == 0
  end

  protected

  def init_values
    if carpark.blank?
      self.price ||= 1
      self.reduced_price ||= 1
    else
      self.price ||= carpark.price
      self.reduced_price ||= carpark.reduced_price
    end
  end

  def different_carpark_user?
    carpark.user != user
  end

  def validate_different_carpark_user
    errors.add(:user, I18n.t('activerecord.errors.models.booking.owner')) unless different_carpark_user?
  end

  def validate_balance
      errors.add(:user, I18n.t('activerecord.errors.models.booking.not_enough_balance')) unless has_enough_balance?
  end

  def has_enough_balance?
    self.user.not_committed_balance >= total_amount
  end

  def ensure_has_not_booking_times
    return true if booking_times.count == 0
    return false
  end

  def ensure_has_not_booking_times_paid
    return true if self.can_edit?
    errors.add(:booking_times, I18n.t('activerecord.errors.models.booking.already_paid'))
    return false
  end

end
