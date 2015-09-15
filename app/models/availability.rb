class Availability < ActiveRecord::Base
  include TimeSpan

  DEFAULT_RENT = "General"

  belongs_to :rent

  acts_as_time_span

  validates_associated :rent
  validates_presence_of :start_time, :end_time
  validate :validate_overlaps, if: Proc.new { |availability| !availability.rent.nil? }
  # after_validation :check_joins
  after_save :ensure_has_rent

  before_destroy :ensure_has_not_bookings


  scope :not_id, ->(id) { where(['availabilities.id <> ?', id.to_i]) }
  scope :next, -> { where(['availabilities.start_time > ?', DateTime.now]) }

  def start_overlap?
    !rent.carpark.get_availabilities.in_same_day(start_time).not_id(id).starts_before(start_time).ends_after(start_time).count.zero?
  end

  def end_overlap?
    !rent.carpark.get_availabilities.in_same_day(start_time).not_id(id).starts_before(fixed_end_time).ends_after(fixed_end_time).count.zero?
  end

  def inner_overlap?
    !rent.carpark.get_availabilities.in_same_day(start_time).not_id(id).starts_before(start_time).ends_after(fixed_end_time).count.zero?
  end

  def wrapper_overlap?
    !rent.carpark.get_availabilities.in_same_day(start_time).not_id(id).starts_after(start_time).ends_before(fixed_end_time).count.zero?
  end

  def overlap?
    start_overlap? || end_overlap? || inner_overlap? || wrapper_overlap?
  end

  protected

  def ensure_has_rent
    if self.rent.blank?
      self.rent = self.rent.carpark.rents.find_or_create_by_name DEFAULT_RENT
      self.save
    end
  end

  #
  # def check_joins
  #   case errors.count
  #     when 1 then
  #       if errors.has_key? :start_overlap
  #         start_join
  #         errors.clear
  #       elsif errors.has_key? :end_overlap
  #         end_join
  #         errors.clear
  #       end
  #     when 2 then
  #       if errors.keys.sort == [:start_overlap, :end_overlap].sort || errors.keys.sort == [:start_overlap, :duration].sort
  #         start_join
  #         errors.clear
  #       elsif errors.keys.sort == [:duration, :end_overlap].sort
  #         end_join
  #         errors.clear
  #       end
  #     when 3 then
  #       if errors.keys.sort == [:start_overlap, :duration, :end_overlap].sort
  #         start_join
  #         errors.clear
  #       end
  #   end
  #   return true
  # end
  #
  # def start_join
  #   overlaps = carpark.availabilities.not_id(id).contain(start_time)
  #   if overlaps.any?
  #     overlap = overlaps.first
  #     if self.new_record?
  #       overlap.end_time = end_time
  #       self.destroy
  #       overlap.save
  #     else
  #       self.start_time = overlap.start_time
  #       overlap.destroy
  #       self.save
  #     end
  #   end
  # end
  #
  # def end_join
  #   overlaps = carpark.availabilities.not_id(id).contain(fixed_end_time)
  #   if overlaps.any?
  #     overlap = overlaps.first
  #     if self.new_record?
  #       overlap.start_time = start_time
  #       self.destroy
  #       overlap.save
  #     else
  #       self.end_time = overlap.end_time
  #       overlap.destroy
  #       self.save
  #     end
  #   end
  # end

  def validate_overlaps
    errors.add(:start_overlap, I18n.t('activerecord.errors.models.availability.start_overlap')) if start_overlap?
    errors.add(:end_overlap, I18n.t('activerecord.errors.models.availability.end_overlap')) if end_overlap?
    errors.add(:inner_overlap, I18n.t('activerecord.errors.models.availability.inner_overlap')) if inner_overlap?
    errors.add(:wrapper_overlap, I18n.t('activerecord.errors.models.availability.wrapper_overlap')) if wrapper_overlap?
  end

  private

  def ensure_has_not_bookings
    if !rent.carpark.get_booking_times.starts_after(start_time).ends_before(end_time).count.zero?
      errors[:destroy] << I18n.t('activerecord.errors.models.availability.exists_booking')
      return false
    end
  end

end
