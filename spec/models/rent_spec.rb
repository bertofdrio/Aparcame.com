#encoding: UTF-8
require 'rails_helper'

describe Rent do

  describe 'when create' do
    context 'without carpark' do
      let(:rent) { build(:rent, carpark: nil) }
      before { rent.valid? }
      subject { rent }
      it { is_expected.to_not be_valid }
      it { expect(rent.errors[:carpark]).to include(I18n.translate('errors.messages.blank')) }
    end

    context 'with carpark' do
      let(:rent) { build(:rent) }
      before { rent.valid? }
      subject { rent }

      it { is_expected.to be_valid }
    end

    context 'without a unique name in the same carpark' do
      let(:one_rent) { FactoryGirl.create(:rent) }
      let(:rent) { build(:rent, name: one_rent.name, carpark: one_rent.carpark) }
      before { rent.valid? }
      subject { rent }

      it { is_expected.to_not be_valid }
      it { expect(rent.errors[:name]).to include(I18n.translate('activerecord.errors.models.rent.should_be_unique_carpark')) }
    end

    context 'with a not unique name in different carparks' do
      let(:one_rent) { FactoryGirl.create(:rent) }
      let(:rent) { build(:rent, name: one_rent.name, carpark: build(:carpark)) }
      subject { rent }

      it { is_expected.to be_valid }
    end

    context 'with a unique name in the same carpark' do
      let(:one_rent) { FactoryGirl.create(:rent) }
      let(:rent) { build(:rent, name: 'Unique name' ) }
      subject { rent }

      it { is_expected.to be_valid }
    end
  end

  describe 'when delete' do
    let(:rent) { create(:rent_few_availabilities) }

    it 'fails with availabilities with bookings but delete availabilities without bookings' do

      booking = create(:booking, carpark: rent.carpark)
      create(:booking_time, booking: booking, start_time: rent.availabilities.first.start_time + TimeSpan::MINIMUN_MINUTES_SEGMENT.minutes,
             end_time: rent.availabilities.first.end_time - 2* TimeSpan::MINIMUN_MINUTES_SEGMENT.minutes)


      rent.delete_availabilities_without_booking
      rent.destroy

      expect(rent.destroyed?).to be false
      expect(rent.errors[:base]).to include(I18n.translate('activerecord.errors.messages.restrict_dependent_destroy.many') % {:record => "availabilities"})

      expect(rent.availabilities.count).to be 1
    end

    it "pass deleting rent with availabilities without bookings" do
      rent.delete_availabilities_without_booking
      rent.destroy

      expect(rent.destroyed?).to be true
    end

  end

end