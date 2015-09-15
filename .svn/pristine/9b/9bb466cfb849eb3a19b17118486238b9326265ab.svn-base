class GateTask < ActiveRecord::Base
  enum action: { in: 0, out: 1 }

  belongs_to :booking_time

  validates_presence_of :user_phone, :garage_phone, :booking_time, :time
  validates_uniqueness_of :action, :scope => :booking_time_id

  validates_format_of :user_phone, :with => /\d{9}/i, message: I18n.t('activerecord.errors.models.user.invalid')
  validates_format_of :garage_phone, :with => /\d{9}/i, message: I18n.t('activerecord.errors.models.user.invalid')
end
