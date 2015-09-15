#encoding: UTF-8
require 'rails_helper'

describe Availability do

  describe 'when create' do
    context "in normal save" do
      let(:availability) { build(:availability) }
      before { availability.valid? }
      subject { availability }

      it { expect(availability.rent).to be_valid }
      it { is_expected.to be_valid }

      it "should have correct duration" do
        expect(availability.duration_in_seconds).to eq availability.end_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes - availability.start_time
        expect(availability.duration_in_minutes).to eq (availability.end_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes - availability.start_time) / 60
        expect(availability.duration_in_hours).to eq BigDecimal((availability.end_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes - availability.start_time) / 3600, 2)
      end
    end

    context "checking times" do
      let(:availability) { build(:availability) }
      let(:middle) { availability.start_time + (availability.duration_in_minutes / 2).minutes }
      before { availability.save }
      subject { availability }

      it "should contain middle time" do
        expect(availability.contain?(middle)).to be_truthy
      end

      it "should contain limit times" do
        expect(availability.contain?(availability.start_time)).to be_truthy
        expect(availability.contain?(availability.start_time + availability.duration_in_minutes.minutes)).to be_truthy
      end

      it "should not contain near limit times" do
        expect(availability.contain?(availability.start_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes)).to be_falsey
        expect(availability.contain?(availability.start_time + availability.duration_in_minutes.minutes + Availability::MINIMUN_MINUTES_SEGMENT.minutes)).to be_falsey
      end

      it "should contain near limit inner times" do
        expect(availability.contain?(availability.start_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes)).to be_truthy
        expect(availability.contain?(availability.start_time + availability.duration_in_minutes.minutes - Availability::MINIMUN_MINUTES_SEGMENT.minutes)).to be_truthy
      end

      it "should exist containing middle time" do
        expect(availability.rent.availabilities.contain(middle).length).to be 1
      end

      it "should exist containing limit times" do
        expect(Availability.contain(availability.start_time).count).to be 1
        expect(Availability.contain(availability.start_time + availability.duration_in_minutes.minutes).count).to be 1
      end

      it "should not exist containing near limit times" do
        expect(Availability.contain(availability.start_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes).count).to be 0
        expect(Availability.contain(availability.start_time + availability.duration_in_minutes.minutes + Availability::MINIMUN_MINUTES_SEGMENT.minutes).count).to be 0
      end

      it "should nexpect(ot exist containing near limit inner times" do
        expect(Availability.contain(availability.start_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes).count).to be 1
        expect(Availability.contain(availability.start_time + availability.duration_in_minutes.minutes - Availability::MINIMUN_MINUTES_SEGMENT.minutes).count).to be 1
      end

      it "should exist in the same month than start" do
        expect(Availability.in_same_month(availability.start_time).count).to be 1
      end

      it "should exist in the same month than middle" do

        expect(Availability.in_same_month(middle).count).to be 1
      end

      it "should exist in the same month than a date in other month" do
        expect(Availability.in_same_month(availability.start_time + 1.month).count).to be 0
        expect(Availability.in_same_month(availability.start_time - 1.month).count).to be 0
        expect(Availability.in_same_month(availability.start_time + 2.month).count).to be 0
        expect(Availability.in_same_month(availability.start_time - 2.month).count).to be 0
      end

      it "should exist in the same day than start" do
        expect(Availability.in_same_day(availability.start_time).count).to be 1
      end

      it "should exist in the same day than middle" do
        expect(Availability.in_same_day(middle).count).to be 1
      end

      it "should exist in the same day than a date in other day" do
        expect(Availability.in_same_day(availability.start_time + 1.day).count).to be 0
        expect(Availability.in_same_day(availability.start_time - 1.day).count).to be 0
        expect(Availability.in_same_day(availability.start_time + 2.day).count).to be 0
        expect(Availability.in_same_day(availability.start_time - 2.day).count).to be 0
      end

    end

    context "checking overlaps" do
      let(:availability) { build(:availability) }
      before { availability.save }

      it "should overlaps at start" do
        overlap_availability = availability.rent.availabilities.build(:start_time => availability.end_time - 1.hours, :end_time => availability.end_time + 1.hours)

        expect(overlap_availability.start_overlap?).to be_truthy
        expect(overlap_availability.end_overlap?).to be_falsey
        expect(overlap_availability.inner_overlap?).to be_falsey
        expect(overlap_availability.wrapper_overlap?).to be_falsey
        expect(overlap_availability.overlap?).to be_truthy
      end

      it "should overlaps at end" do
        overlap_availability = availability.rent.availabilities.build(:start_time => availability.start_time - 1.hours, :end_time => availability.start_time + 1.hours)

        expect(overlap_availability.start_overlap?).to be_falsey
        expect(overlap_availability.end_overlap?).to be_truthy
        expect(overlap_availability.inner_overlap?).to be_falsey
        expect(overlap_availability.wrapper_overlap?).to be_falsey
        expect(overlap_availability.overlap?).to be_truthy
      end

      it "should had an inner overlap" do
        overlap_availability = availability.rent.availabilities.build(:start_time => availability.start_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                                      :end_time => availability.end_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes)

        expect(overlap_availability.start_overlap?).to be_truthy
        expect(overlap_availability.end_overlap?).to be_truthy
        expect(overlap_availability.inner_overlap?).to be_truthy
        expect(overlap_availability.wrapper_overlap?).to be_falsey
        expect(overlap_availability.overlap?).to be_truthy
      end

      it "should had an wrapper overlap" do
        overlap_availability = availability.rent.availabilities.build(:start_time => availability.start_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                                      :end_time => availability.end_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes)

        expect(overlap_availability.start_overlap?).to be_falsey
        expect(overlap_availability.end_overlap?).to be_falsey
        expect(overlap_availability.inner_overlap?).to be_falsey
        expect(overlap_availability.wrapper_overlap?).to be_truthy
        expect(overlap_availability.overlap?).to be_truthy
      end

      it "should not had overlaps" do
        start_time = availability.end_time + (2*Availability::MINIMUN_MINUTES_SEGMENT.minutes)
        overlap_availability = availability.rent.availabilities.build(:start_time => start_time,
                                                                      :end_time => start_time + 2.hours)

        expect(overlap_availability.start_overlap?).to be_falsey
        expect(overlap_availability.end_overlap?).to be_falsey
        expect(overlap_availability.inner_overlap?).to be_falsey
        expect(overlap_availability.wrapper_overlap?).to be_falsey
        expect(overlap_availability.overlap?).to be_falsey
      end

      it "should not had overlaps in diferent days" do
        date = (DateTime.now.beginning_of_month + 1.days).beginning_of_day

        availability.start_time = date - 2.hours
        availability.end_time = date - Availability::MINIMUN_MINUTES_SEGMENT.minutes
        availability.save

        start_time = (date + 1.days).beginning_of_day
        overlap_availability = availability.rent.availabilities.build(:start_time => start_time,
                                                                      :end_time => start_time + 2.hours)

        expect(overlap_availability.start_overlap?).to be_falsey
        expect(overlap_availability.end_overlap?).to be_falsey
        expect(overlap_availability.inner_overlap?).to be_falsey
        expect(overlap_availability.wrapper_overlap?).to be_falsey
        expect(overlap_availability.overlap?).to be_falsey
      end
    end

    context "checking validations" do
      before { Time.zone = ("Europe/Madrid"); }
      let(:date) { DateTime.now.beginning_of_month.getutc }
      before { Timecop.freeze(date); }

      context "with less than 90 min" do
        let(:availability) { build(:availability, start_time: date + 1.hours, end_time: date + 2.hours) }
        before { availability.valid? }
        subject { availability }

        it { is_expected.to_not be_valid }
        it { expect(availability.errors[:duration]).to include(I18n.t('activerecord.errors.models.availability.invalid_duration', :duration =>  TimeSpan::MINIMUN_MINUTES_DURATION)) }
      end

      context "pass validation with more than 90 min" do
        let(:availability) { build(:availability, start_time: date + 2.hours, end_time: date + 4.hours) }
        subject { availability }

        it { is_expected.to be_valid }
      end

      context "with different day" do
        let(:availability) { build(:availability, start_time: date + 1.day - 1.hours, end_time: date + 1.day + 1.hours) }
        before { availability.valid? }
        subject { availability }

        it { is_expected.to_not be_valid }
        it { expect(availability.errors[:end_time]).to include(I18n.t('activerecord.errors.models.availability.attributes.end_time.not_same_day', :duration =>  TimeSpan::MINIMUN_MINUTES_DURATION)) }
      end

      context "overlaps another availability at start" do
        let(:availability) { build(:availability) }
        before { availability.save }
        let(:overlap_availability) { availability.rent.availabilities.build(:start_time => availability.end_time - 1.hour,
                                                                :end_time => availability.start_time + 1.hour) }

        before { overlap_availability.valid? }
        subject { overlap_availability }

        it { is_expected.to_not be_valid }
        it { expect(overlap_availability.errors[:start_overlap]).to include(I18n.t('activerecord.errors.models.availability.start_overlap')) }
      end

      context "overlaps another availability at end" do
        let(:availability) { build(:availability) }
        before { availability.save }
        let(:overlap_availability) { availability.rent.availabilities.build(:start_time => availability.start_time - 1.hour,
                                                                :end_time => availability.start_time + 1.hour) }

        before { overlap_availability.valid? }
        subject { overlap_availability }

        it { is_expected.to_not be_valid }
        it { expect(overlap_availability.errors[:end_overlap]).to include(I18n.t('activerecord.errors.models.availability.end_overlap')) }
      end

      context "is inside another availability" do
        let(:availability) { build(:availability) }
        before { availability.save }
        let(:overlap_availability) { availability.rent.availabilities.build(:start_time => availability.start_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                                :end_time => availability.end_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes) }

        before { overlap_availability.valid? }
        subject { overlap_availability }

        it { is_expected.to_not be_valid }
        it { expect(overlap_availability.errors[:start_overlap]).to include(I18n.t('activerecord.errors.models.availability.start_overlap')) }
        it { expect(overlap_availability.errors[:end_overlap]).to include(I18n.t('activerecord.errors.models.availability.end_overlap')) }
        it { expect(overlap_availability.errors[:inner_overlap]).to include(I18n.t('activerecord.errors.models.availability.inner_overlap')) }
      end

      context "wraps another availability" do
        let(:availability) { build(:availability) }
        before { availability.save }
        let(:overlap_availability) { availability.rent.availabilities.build(:start_time => availability.start_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                                :end_time => availability.end_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes) }

        before { overlap_availability.valid? }
        subject { overlap_availability }

        it { is_expected.to_not be_valid }
        it { expect(overlap_availability.errors[:wrapper_overlap]).to include(I18n.t('activerecord.errors.models.availability.wrapper_overlap')) }
      end

      context "ends before starts" do
        let(:availability) { build(:availability, start_time: date + 3.hours, end_time: date - 2.hours) }
        before { availability.valid? }
        subject { availability }

        it { is_expected.to_not be_valid }
        it { expect(availability.errors[:start_time]).to include(I18n.t('activerecord.errors.models.availability.attributes.start_time.start_before_end', :duration =>  TimeSpan::MINIMUN_MINUTES_DURATION)) }
      end

      context "starts before one hour in advance" do
        let(:availability) { build(:availability, start_time: date, end_time: date + 3.hours) }
        before { availability.valid? }
        subject { availability }

        it { is_expected.to_not be_valid }
        it { expect(availability.errors[:start_time]).to include(I18n.t('activerecord.errors.models.availability.attributes.start_time.invalid_margin_start')) }
      end

      context "starts just one hour in advance" do
        let(:availability) { build(:availability, start_time: date + 1.hours, end_time: date + 3.hours) }
        before { availability.valid? }
        subject { availability }

        it { is_expected.to be_valid }
      end

      context "starts after one hour in advance" do
        let(:availability) { build(:availability, start_time: DateTime.now + 2.hours, end_time: DateTime.now + 4.hours) }
        before { availability.valid? }
        subject { availability }

        it { is_expected.to be_valid }
      end

      context 'start is empty' do
        let(:availability) { build(:availability, start_time: nil) }
        before { availability.valid? }
        subject { availability }

        it { is_expected.to_not be_valid }
      end

      context 'end is empty' do
        let(:availability) { build(:availability, end_time: nil) }
        before { availability.valid? }
        subject { availability }

        it { is_expected.to_not be_valid }
      end

    end

  end

  describe 'when delete' do

    context "cannot delete availability if exists booking_time inner_overlap " do
      # @booking = bookings(:booking_one)
      # @booking_time = @booking.booking_times.build(start_time: Date.today + 1.week + 5.hours + TimeSpan::MINIMUN_MINUTES_SEGMENT.minutes,
      #                                              end_time: Date.today + 1.week + 7.hours - 2 * TimeSpan::MINIMUN_MINUTES_SEGMENT.minutes)
      # @booking_time.save
      #
      # @availability.destroy
      #
      # assert_not @availability.destroyed?
      # assert_equal @availability.errors[:destroy], [I18n.t('activerecord.errors.models.availability.exists_booking')]
    end

    context "can delete availability if not exists booking_time inner_overlap " do
      # # creamos primero una disponibilidad para la reserva
      # start_time = @availability.start_time + 4.hours
      # end_time = start_time + 2.hours
      # new_availability = @rent.availabilities.build(:start_time => start_time, :end_time => end_time)
      # new_availability.save
      #
      # # despues la propia reserva
      # @booking = bookings(:booking_one)
      # @booking_time = @booking.booking_times.build(start_time: start_time + TimeSpan::MINIMUN_MINUTES_SEGMENT.minutes,
      #                                              end_time: end_time - TimeSpan::MINIMUN_MINUTES_SEGMENT.minutes)
      # @booking.save
      #
      # # finalmente intentamos destruir la disponibilidad sin reservas
      # @availability.destroy
      #
      # assert @availability.destroyed?
    end

  end
end