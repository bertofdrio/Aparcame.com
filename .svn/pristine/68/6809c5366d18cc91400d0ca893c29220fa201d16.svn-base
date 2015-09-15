require 'rails_helper'

RSpec.describe GateTask, :type => :model do

  it 'is valid whit booking_time, user_phone, garage_phone, time and action' do
    expect(build(:gate_task)).to be_valid
  end

  it "is invalid without booking_time" do
    gate_task = build(:gate_task, booking_time: nil)
    gate_task.valid?
    expect(gate_task.errors[:booking_time]).to include(I18n.t('errors.messages.blank'))
  end

  it "is invalid without user_phone" do
    gate_task = build(:gate_task, user_phone: nil)
    gate_task.valid?
    expect(gate_task.errors[:user_phone]).to include(I18n.t('errors.messages.blank'))
  end

  it "is invalid without garage_phone" do
    gate_task = build(:gate_task, garage_phone: nil)
    gate_task.valid?
    expect(gate_task.errors[:garage_phone]).to include(I18n.t('errors.messages.blank'))
  end

  it "is invalid without time" do
    gate_task = build(:gate_task, time: nil)
    gate_task.valid?
    expect(gate_task.errors[:time]).to include(I18n.t('errors.messages.blank'))
  end

  it "is invalid with same action and booking_time time" do
    create(:gate_task)
    gate_task = build(:gate_task, booking_time: GateTask.first.booking_time)
    gate_task.valid?
    expect(gate_task.errors[:action]).to include(I18n.t('errors.messages.taken'))
  end

  it "is valid with different action and same booking_time time" do
    create(:gate_task)
    expect(build(:gate_task, booking_time: GateTask.first.booking_time, action: :out)).to be_valid
  end
end
