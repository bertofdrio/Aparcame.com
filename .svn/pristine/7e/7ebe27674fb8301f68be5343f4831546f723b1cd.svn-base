#encoding: UTF-8
require 'rails_helper'

describe Booking do

  describe 'when create' do

    context 'without carpark' do
      let(:booking) { build(:booking, carpark: nil) }
      before { booking.valid? }
      subject { booking }

      it { is_expected.to_not be_valid }
      it { expect(booking.errors[:carpark]).to include(I18n.translate('errors.messages.blank')) }
    end

    context 'without a user' do
      let(:booking) { build(:booking, user: nil) }
      before { booking.valid? }
      subject { booking }

      it { is_expected.to_not be_valid }
      it { expect(booking.errors[:user]).to include(I18n.translate('errors.messages.blank')) }
    end

    context 'without a license and phone' do
      let(:booking) { build(:booking, license: "", phone: "") }
      before { booking.valid? }
      subject { booking }

      it { is_expected.to_not be_valid }
      it { expect(booking.errors[:license]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(booking.errors[:phone]).to include(I18n.translate('errors.messages.blank')) }
    end

    context 'with a carpark, user, license, phone and prices' do
      let(:booking) { build(:booking) }
      before { booking.valid? }
      subject { booking }

      it { is_expected.to be_valid }
    end

    context 'with a carpark which user is owner of' do
      let(:booking) { build(:booking) }
      before { booking.user = booking.carpark.user }
      before { booking.valid? }
      subject { booking }

      it { is_expected.to_not be_valid }
      it { expect(booking.errors[:user]).to include(I18n.t('activerecord.errors.models.booking.owner')) }
    end
  end

  describe 'when delete' do

    let(:rent) { create(:rent_few_availabilities) }
    let(:booking) { build(:booking, carpark: rent.carpark) }

    before {
      rent.availabilities.each do |availability|
        booking.booking_times  << FactoryGirl.build(:booking_time,
                                                  start_time: availability.start_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                  end_time: availability.end_time - 2 * Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                  booking: booking)
      end
    }

    it 'destroy all the booking_times associated' do

      booking.save
      booking.valid?

      expect(booking).to be_valid

      booking.delete_booking_times_not_paid
      booking.destroy

      expect(booking.destroyed?).to be true
      expect(BookingTime.all.count).to be 0
    end

    it 'fails deleting booking with booking_times already paid but delete booking_times not paid' do

      booking.booking_times.first.paid = true
      booking.save

      booking.delete_booking_times_not_paid
      booking.destroy

      expect(booking.destroyed?).to be false
      expect(booking.errors[:base]).to include(I18n.translate('activerecord.errors.messages.restrict_dependent_destroy.many') % {:record => "booking times"})

      expect(booking.booking_times.count).to be 1
      expect(BookingTime.all.count).to be 1
    end
  end

  describe 'when balance' do

    let(:rent) { create(:rent_few_availabilities) }
    let(:booking) { build(:booking, carpark: rent.carpark) }

    let(:booking_time) { booking.booking_times.build(start_time: rent.availabilities.first.start_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                    end_time: rent.availabilities.first.end_time - 2 * Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                    booking: booking) }

    context 'user has not enough balance' do

      before { booking.user.balance = booking_time.total_amount - 1.0 }
      before { booking.valid? }
      subject { booking }

      it { is_expected.to_not be_valid }
      it { expect(booking.errors[:user]).to include(I18n.t('activerecord.errors.models.booking.not_enough_balance')) }
    end

    context 'user has enough total balance but has part committed' do

      before { booking.user.balance = booking_time.total_amount }
      before { booking.save }

      let(:another_booking) { build(:booking, user: booking.user, carpark: rent.carpark) }
      let(:another_booking_time) { another_booking.booking_times.build(start_time: rent.availabilities.second.start_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                                       end_time: rent.availabilities.second.end_time - 2 * Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                                       booking: another_booking) }

        context 'but has part committed' do

          before { booking.user.balance += another_booking_time.total_amount/2 }
          before { booking.save }
          before { another_booking.valid? }
          subject { another_booking }

          it { is_expected.to_not be_valid }
          it { expect(another_booking.errors[:user]).to include(I18n.t('activerecord.errors.models.booking.not_enough_balance')) }
          it { expect(booking.user.balance).to be >= another_booking.total_amount }

        end

        context 'user has enough total balance although has part committed' do

          before { booking.user.balance += another_booking_time.total_amount }
          before { booking.save }
          subject { another_booking }

          it { is_expected.to be_valid }
        end
    end


  end
end