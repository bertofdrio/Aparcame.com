# TimeSpan

require 'active_support/concern'

module TimeSpan
  MINIMUN_MINUTES_DURATION = 90
  MINIMUN_HOURS_MARGIN = 1
  MINIMUN_MINUTES_SEGMENT = 15

  extend ActiveSupport::Concern

#  public
  # module InstanceMethods

    def duration_in_seconds
      fixed_end_time - start_time
    end

    def duration_in_minutes
      duration_in_seconds / 60
    end

    def duration_in_hours
      BigDecimal.new(duration_in_minutes / 60, 2)
    end

    def same_day?
      start_time.to_date.eql? end_time.to_date
    end

    def contain?(date)
      start_time <= date && fixed_end_time >= date
    end

    def validate_same_day
      errors.add(:end_time, :not_same_day) unless same_day?
    end

    def validate_times_order
      errors.add(:start_time, :start_before_end) if start_time >= fixed_end_time
    end

    def validate_day_margin
      errors.add(:start_time, :invalid_margin_start) if start_time < DateTime.now + MINIMUN_HOURS_MARGIN.hours
    end

    def validate_duration
      # La internacionalización de este error debe ser manual porque no es sobre un atributo real
      errors.add(:duration, I18n.t('activerecord.errors.models.availability.invalid_duration', :duration =>  self.minimum_minutes_duration)) if duration_in_minutes < self.minimum_minutes_duration
    end

    def fixed_end_time
      end_time + MINIMUN_MINUTES_SEGMENT.minutes
    end

  protected

  def ensure_times_not_empty
    self.start_time ||= Date.today
    self.end_time ||= Date.today
  end

  # end


  included do
    scope :starts_after, ->(date = DateTime.now) { where(['start_time >= ?', date]) }
    scope :ends_before, ->(date = DateTime.now) { where(['end_time <= ?', date - MINIMUN_MINUTES_SEGMENT.minutes]) }
    scope :in_same_month, ->(date = DateTime.now) { starts_after(date.beginning_of_month).where(['end_time <= ?', date.end_of_month]) }
    scope :in_same_day, ->(date = DateTime.now) { starts_after(date.beginning_of_day).ends_before(date.end_of_day) }

    scope :starts_before, ->(date = DateTime.now) { where(['start_time <= ?', date]) }
    scope :ends_after, ->(date = DateTime.now) { where(['end_time >= ?', date - MINIMUN_MINUTES_SEGMENT.minutes]) }
    scope :contain, ->(date = DateTime.now) { starts_before(date).ends_after(date) }

    validate :validate_same_day, :validate_times_order, :validate_day_margin, :validate_duration
    # Se omite la validación del margen de una hora para crear disponibilidades
    # porque al crearlas masivamente si falla alguna por eso, no se crea ninguna
    # Al quitarlo se producen errores en las pruebas que validaban eso
    #base.validate :validate_same_day, :validate_times_order, :validate_duration
    before_validation :ensure_times_not_empty

    # Creamos un atributo para la validaciónd e la duración, ya que dependerá de la clase
    # Se inicializa por aprametro desde el acts_as
    cattr_accessor :minimum_minutes_duration
  end

  module ClassMethods
    def acts_as_time_span(options = {})
      self.minimum_minutes_duration = (options[:minimum_minutes_duration] || MINIMUN_MINUTES_DURATION)
    end
  end
end
