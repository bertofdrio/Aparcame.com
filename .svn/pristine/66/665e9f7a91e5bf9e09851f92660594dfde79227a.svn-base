class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable

  has_many :carparks
  has_many :bookings
  has_many :transactions
  validates_numericality_of :balance, :greater_than_or_equal_to => BigDecimal(0.0, 2)
  validates_format_of :phone, :with => /\d{9}/i, message: I18n.t('activerecord.errors.models.user.invalid'), unless: Proc.new { |user| user.phone.blank? }
  validates_format_of :license, :with => /(\d{4}-[\D\w]{3}|[\D\w]{1,2}-\d{4}-[\D\\w]{2})/i, message: I18n.t('activerecord.errors.models.user.invalid'), unless: Proc.new { |user| user.license.blank? }
  validate :validate_dni, unless: Proc.new { |user| user.dni.blank? }
  validates_length_of :name, maximum: 50, unless: Proc.new { |user| user.name.nil? }
  validates_length_of :surname, maximum: 50, unless: Proc.new { |user| user.surname.nil? }

  def not_committed_balance
    self.balance - get_committed_balance
  end

  def update_balance(amount)
    User.transaction do
      self.lock!
      self.balance += BigDecimal(amount, 2)
      self.save!
      end
  end

  protected

  def get_committed_balance
    committed_balance = 0
    BookingTime.joins(:booking).where('bookings.user_id = ? AND booking_times.paid = ?', self.id, false)
        .each { |booking_time| committed_balance += booking_time.total_amount }
    return committed_balance
  end

  def validate_dni
    letters = "TRWAGMYFPDXBNJZSQVHLCKE"
    value = 0

    if dni.starts_with? 'X' # es un NIE
      value = dni[1, nif.length-1].to_i
    else
      if dni.starts_with? 'Y' # es un NIE
        value = 10000000 + dni[1, nif.length-1].to_i
      else
        if dni.starts_with? 'Z' #Es un NIE
          value = 20000000 + dni[1, nif.length-1].to_i
        else # Es un NIF
          value = dni.chop.to_i
        end
      end
    end

    if dni.ends_with? letters[(value % 23)] # LA LETRA DEL NIF/NIE ES VÁLIDA
    else # LA LETRA DEL NIE ES ERRONEA
      errors.add(:dni, I18n.t('activerecord.errors.models.user.invalid'))
    end
  end
end
