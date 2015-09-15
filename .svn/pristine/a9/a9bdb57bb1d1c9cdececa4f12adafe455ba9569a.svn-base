require 'rails_helper'

RSpec.describe Charge, :type => :model do

  it 'is valid whit booking_time and paid at' do
    expect(build(:charge)).to be_valid
  end

  it "is invalid without paid_at" do
    charge = build(:charge, booking_time: nil)
    charge.valid?
    expect(charge.errors[:booking_time]).to include(I18n.t('errors.messages.blank'))
  end

  it "is invalid without booking_time" do
    charge = build(:charge, paid_at: nil)
    charge.valid?
    expect(charge.errors[:paid_at]).to include(I18n.t('errors.messages.blank'))
  end

end
