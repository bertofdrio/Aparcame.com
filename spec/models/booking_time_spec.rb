#encoding: UTF-8
require 'rails_helper'

describe BookingTime do

  describe 'when create' do
    context 'in normal save' do
      let(:booking_time) { build(:booking_time_with_availability) }
      before { booking_time.valid? }
      subject { booking_time }

      it { expect(booking_time.booking).to be_valid }
      it { is_expected.to be_valid }

      it 'should have correct duration' do
        expect(booking_time.duration_in_seconds).to eq booking_time.end_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes - booking_time.start_time
        expect(booking_time.duration_in_minutes).to eq (booking_time.end_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes - booking_time.start_time) / 60
        expect(booking_time.duration_in_hours).to eq BigDecimal((booking_time.end_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes - booking_time.start_time) / 3600, 2)
      end
    end

    context 'checking times' do
      let(:booking_time) { build(:booking_time_with_availability) }
      let(:middle) { booking_time.start_time + (booking_time.duration_in_minutes / 2).minutes }
      before { booking_time.save }
      subject { booking_time }

      it 'should contain middle time' do
        expect(booking_time.contain?(middle)).to be_truthy
      end

      it 'should contain limit times' do
        expect(booking_time.contain?(booking_time.start_time)).to be_truthy
        expect(booking_time.contain?(booking_time.start_time + booking_time.duration_in_minutes.minutes)).to be_truthy
      end

      it 'should not contain near limit times' do
        expect(booking_time.contain?(booking_time.start_time - BookingTime::MINIMUN_MINUTES_SEGMENT.minutes)).to be_falsey
        expect(booking_time.contain?(booking_time.start_time + booking_time.duration_in_minutes.minutes + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes)).to be_falsey
      end

      it 'should contain near limit inner times' do
        expect(booking_time.contain?(booking_time.start_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes)).to be_truthy
        expect(booking_time.contain?(booking_time.start_time + booking_time.duration_in_minutes.minutes - BookingTime::MINIMUN_MINUTES_SEGMENT.minutes)).to be_truthy
      end

      it 'should exist containing middle time' do
        expect(booking_time.booking.booking_times.contain(middle).length).to be 1
      end

      it 'should exist containing limit times' do
        expect(BookingTime.contain(booking_time.start_time).count).to be 1
        expect(BookingTime.contain(booking_time.start_time + booking_time.duration_in_minutes.minutes).count).to be 1
      end

      it 'should not exist containing near limit times' do
        expect(BookingTime.contain(booking_time.start_time - BookingTime::MINIMUN_MINUTES_SEGMENT.minutes).count).to be 0
        expect(BookingTime.contain(booking_time.start_time + booking_time.duration_in_minutes.minutes + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes).count).to be 0
      end

      it 'should not exist containing near limit inner times' do
        expect(BookingTime.contain(booking_time.start_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes).count).to be 1
        expect(BookingTime.contain(booking_time.start_time + booking_time.duration_in_minutes.minutes - BookingTime::MINIMUN_MINUTES_SEGMENT.minutes).count).to be 1
      end

      it 'should exist in the same month than start' do
        expect(BookingTime.in_same_month(booking_time.start_time).count).to be 1
      end

      it 'should exist in the same month than middle' do
        expect(BookingTime.in_same_month(middle).count).to be 1
      end

      it 'should exist in the same month than a date in other month' do
        expect(BookingTime.in_same_month(booking_time.start_time + 1.month).count).to be 0
        expect(BookingTime.in_same_month(booking_time.start_time - 1.month).count).to be 0
        expect(BookingTime.in_same_month(booking_time.start_time + 2.month).count).to be 0
        expect(BookingTime.in_same_month(booking_time.start_time - 2.month).count).to be 0
      end

      it 'should exist in the same day than start' do
        expect(BookingTime.in_same_day(booking_time.start_time).count).to be 1
      end

      it 'should exist in the same day than middle' do
        expect(BookingTime.in_same_day(middle).count).to be 1
      end

      it 'should exist in the same day than a date in other day' do
        expect(BookingTime.in_same_day(booking_time.start_time + 1.day).count).to be 0
        expect(BookingTime.in_same_day(booking_time.start_time - 1.day).count).to be 0
        expect(BookingTime.in_same_day(booking_time.start_time + 2.day).count).to be 0
        expect(BookingTime.in_same_day(booking_time.start_time - 2.day).count).to be 0
      end

    end

    context "checking validations" do
      before { Time.zone = ("Europe/Madrid"); }
      let(:date) { DateTime.now.beginning_of_month.getutc }
      before { Timecop.freeze(date); }

      context "with less than 60 min" do
        let(:booking_time) { build(:booking_time_with_availability, start_time: date + 1.hours, end_time: date + 1.hours) }
        before { booking_time.valid? }
        subject { booking_time }

        it { is_expected.to_not be_valid }
        it { expect(booking_time.errors[:duration]).to include(I18n.t('activerecord.errors.models.availability.invalid_duration', :duration => booking_time.minimum_minutes_duration)) }
      end

      context "pass validation with more than 60 min" do
        let(:booking_time) { build(:booking_time_with_availability, start_time: date + 3.hours, end_time: date + 4.hours) }
        subject { booking_time }

        it { is_expected.to be_valid }
      end

      context 'with different day' do
        let(:booking_time) { build(:booking_time_with_availability, start_time: date + 1.day - 1.hours, end_time: date + 1.day + 1.hours) }
        before { booking_time.valid? }
        subject { booking_time }

        it { is_expected.to_not be_valid }
        it { expect(booking_time.errors[:end_time]).to include(I18n.t('activerecord.errors.models.availability.attributes.end_time.not_same_day', :duration => TimeSpan::MINIMUN_MINUTES_DURATION)) }
      end

      context 'ends before starts' do
        let(:booking_time) { build(:booking_time_with_availability, start_time: date + 3.hours, end_time: date - 2.hours) }
        before { booking_time.valid? }
        subject { booking_time }

        it { is_expected.to_not be_valid }
        it { expect(booking_time.errors[:start_time]).to include(I18n.t('activerecord.errors.models.availability.attributes.start_time.start_before_end', :duration => TimeSpan::MINIMUN_MINUTES_DURATION)) }
      end

      context 'start is empty' do
        let(:booking_time) { build(:booking_time, start_time: nil) }
        before { booking_time.valid? }
        subject { booking_time }

        it { is_expected.to_not be_valid }
      end

      context 'end is empty' do
        let(:booking_time) { build(:booking_time, end_time: nil) }
        before { booking_time.valid? }
        subject { booking_time }

        it { is_expected.to_not be_valid }
      end
    end

    context 'checking availability validations' do
      let(:booking_time) { build(:booking_time_with_availability) }
      let(:availability) { booking_time.booking.carpark.rents.first.availabilities.first }

      it "fails validation without availability" do
        availability.delete

        expect(booking_time).to_not be_valid
        expect(booking_time.errors[:availability]).to include(I18n.t('activerecord.errors.models.booking_time.not_availabitity'))
      end

      it "fails validation with availability in start overlap" do
        availability.start_time = booking_time.start_time - 1.hours
        availability.end_time = booking_time.start_time + 1.hours
        availability.save

        expect(booking_time).to_not be_valid
        expect(booking_time.errors[:availability]).to include(I18n.t('activerecord.errors.models.booking_time.not_availabitity'))
      end

      it "fails validation with availability in end overlap" do
        availability.start_time = booking_time.start_time + 1.hours
        availability.end_time = booking_time.end_time + 1.hours
        availability.save

        expect(booking_time).to_not be_valid
        expect(booking_time.errors[:availability]).to include(I18n.t('activerecord.errors.models.booking_time.not_availabitity'))
      end

      it "fails validation with availability in inner overlap" do
        availability.start_time = booking_time.start_time + BookingTime::MINIMUN_MINUTES_SEGMENT.minutes
        availability.end_time = booking_time.end_time - BookingTime::MINIMUN_MINUTES_SEGMENT.minutes
        availability.save
        
        expect(booking_time).to_not be_valid
        expect(booking_time.errors[:availability]).to include(I18n.t('activerecord.errors.models.booking_time.not_availabitity'))
      end

      it "fails validation with availability at same start_time" do
        availability.start_time = booking_time.start_time
        availability.save
        
        expect(booking_time).to_not be_valid
        expect(booking_time.errors[:availability]).to include(I18n.t('activerecord.errors.models.booking_time.not_availabitity'))
      end

      it "fails validation with availability at same end_time" do
        availability.end_time = booking_time.end_time
        availability.save
        
        expect(booking_time).to_not be_valid
        expect(booking_time.errors[:availability]).to include(I18n.t('activerecord.errors.models.booking_time.not_availabitity'))
      end

      it "fails validation with availability at same start_time and end_time" do
        availability.start_time = booking_time.start_time
        availability.end_time = booking_time.end_time
        availability.save
        
        expect(booking_time).to_not be_valid
        expect(booking_time.errors[:availability]).to include(I18n.t('activerecord.errors.models.booking_time.not_availabitity'))
      end

      it "pass validation with availability at limit start_time" do
        availability.start_time = booking_time.start_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes
        availability.save

        expect(booking_time).to be_valid
      end

      it "pass validation with availability at limit end_time" do
        availability.end_time = booking_time.end_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes
        availability.save

        expect(booking_time).to be_valid
      end

      it "pass validation with availability at limit start_time and end_time" do
        availability.start_time = booking_time.start_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes
        availability.end_time = booking_time.end_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes
        availability.save

        expect(booking_time).to be_valid
      end
    end

    context "checking overlaps" do
      let(:booking_time) { build(:booking_time_with_availability) }
      before { booking_time.save }

      it "fails validation if overlaps another booking_time at start" do
        overlap_booking_time = booking_time.booking.booking_times.build(:start_time => booking_time.end_time - 1.hours,
                                                                        :end_time => booking_time.end_time + 1.hours)

        expect(overlap_booking_time.start_overlap?).to be_truthy
        expect(overlap_booking_time.end_overlap?).to be_falsey
        expect(overlap_booking_time.inner_overlap?).to be_falsey
        expect(overlap_booking_time.wrapper_overlap?).to be_falsey
        expect(overlap_booking_time.overlap?).to be_truthy
      end

      it "fails validation if overlaps another booking_time at end" do
        overlap_booking_time = booking_time.booking.booking_times.build(:start_time => booking_time.start_time - 1.hours,
                                                                        :end_time => booking_time.start_time + 1.hours)

        expect(overlap_booking_time.start_overlap?).to be_falsey
        expect(overlap_booking_time.end_overlap?).to be_truthy
        expect(overlap_booking_time.inner_overlap?).to be_falsey
        expect(overlap_booking_time.wrapper_overlap?).to be_falsey
        expect(overlap_booking_time.overlap?).to be_truthy
      end

      it "fails validation if is inside another booking_time" do
        overlap_booking_time = booking_time.booking.booking_times.build(:start_time => booking_time.start_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                                        :end_time => booking_time.end_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes)

        expect(overlap_booking_time.start_overlap?).to be_truthy
        expect(overlap_booking_time.end_overlap?).to be_truthy
        expect(overlap_booking_time.inner_overlap?).to be_truthy
        expect(overlap_booking_time.wrapper_overlap?).to be_falsey
        expect(overlap_booking_time.overlap?).to be_truthy
      end

      it "fails validation if wraps another booking_time" do
        overlap_booking_time = booking_time.booking.booking_times.build(:start_time => booking_time.start_time - Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                                        :end_time => booking_time.end_time + Availability::MINIMUN_MINUTES_SEGMENT.minutes)

        expect(overlap_booking_time.start_overlap?).to be_falsey
        expect(overlap_booking_time.end_overlap?).to be_falsey
        expect(overlap_booking_time.inner_overlap?).to be_falsey
        expect(overlap_booking_time.wrapper_overlap?).to be_truthy
        expect(overlap_booking_time.overlap?).to be_truthy
      end

      it "fails validation if limits with another booking_time at start" do
        overlap_booking_time = build(:booking_time_with_availability,
                                     :start_time => booking_time.start_time - 2.hours,
                                     :end_time => booking_time.start_time,
                                     :booking => booking_time.booking)

        expect(overlap_booking_time).to_not be_valid
        expect(overlap_booking_time.errors[:end_overlap]).to include(I18n.t('activerecord.errors.models.booking_time.end_overlap'))
      end

      it "pass validation if limits with another booking_time at start just in the limit" do
        overlap_booking_time = build(:booking_time_with_availability,
                                     :start_time => booking_time.start_time - 2.hours,
                                     :end_time => booking_time.start_time - 2 * BookingTime::MINIMUN_MINUTES_SEGMENT.minutes,
                                     :booking => booking_time.booking)

        expect(overlap_booking_time).to be_valid
      end

      it "fails validation if limits with another booking_time at end" do
        overlap_booking_time = build(:booking_time_with_availability,
                                     :start_time => booking_time.end_time,
                                     :end_time => booking_time.end_time + 2.hours,
                                     :booking => booking_time.booking)

        expect(overlap_booking_time).to_not be_valid
        expect(overlap_booking_time.errors[:start_overlap]).to include(I18n.t('activerecord.errors.models.booking_time.start_overlap'))
      end

      it "pass validation if limits with another booking_time at end just in the limit" do
        overlap_booking_time = build(:booking_time_with_availability,
                                     :start_time => booking_time.end_time + 2 * BookingTime::MINIMUN_MINUTES_SEGMENT.minutes,
                                     :end_time => booking_time.end_time + 2.hours,
                                     :booking => booking_time.booking)

        expect(overlap_booking_time).to be_valid
      end
    end

    context 'checking amount' do

      context 'with price' do
        let(:booking_time) { build(:booking_time_with_availability) }
        subject { booking_time }

        it { expect(booking_time.total_amount).to eq(booking_time.booking.price * booking_time.duration_in_hours) }
      end


      context 'with reduced price' do
        let(:booking_time) { build(:booking_time_with_availability) }
        before { booking_time.end_time = booking_time.start_time + 4.hours }
        subject { booking_time }

        it { expect(booking_time.total_amount).to eq(booking_time.booking.reduced_price * booking_time.duration_in_hours) }
      end
    end
  end


  describe 'when delete' do
    let(:booking_time) { build(:booking_time_with_availability) }
    subject { booking_time }

    context 'booking_time paid' do
      before { booking_time.paid = true; booking_time.destroy; }

      it { expect(booking_time.destroyed?).to be_falsey }
      it { expect(booking_time.errors[:destroy]).to include(I18n.t('activerecord.errors.models.booking_time.already_paid')) }
    end

    context 'booking_time not paid' do
      before { booking_time.destroy; }

      it { expect(booking_time.destroyed?).to be_truthy }

    end
  end
end