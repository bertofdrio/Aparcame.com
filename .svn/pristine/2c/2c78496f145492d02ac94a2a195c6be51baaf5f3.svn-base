#encoding: UTF-8
require 'rails_helper'

describe Garage do

  describe 'when create' do
    context 'with valid data' do
      let(:garage) { build(:garage) }
      subject { garage }

      it { is_expected.to be_valid }
    end

    context "with some empty attribute" do
      let(:garage) { Garage.new }
      before { garage.valid? }
      subject { garage }

      it { is_expected.to_not be_valid }
      it { expect(garage.errors[:address]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(garage.errors[:city]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(garage.errors[:postal_code]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(garage.errors[:phone]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(garage.errors[:latitude]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(garage.errors[:longitude]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(garage.errors[:province]).to include(I18n.translate('errors.messages.blank')) }
    end

    context 'with postal code not a a number' do
      let(:garage) { build(:garage, postal_code: "String") }
      before { garage.valid? }
      subject { garage }

      it { is_expected.to_not be_valid }
      it { expect(garage.errors[:postal_code]).to include(I18n.translate('errors.messages.not_a_number')) }
    end

    context 'with latitude and longitude not numbers' do
      let(:garage) { build(:garage, latitude: "String", longitude: "String") }
      before { garage.valid? }
      subject { garage }

      it { is_expected.to_not be_valid }
      it { expect(garage.errors[:latitude]).to include(I18n.translate('errors.messages.not_a_number')) }
      it { expect(garage.errors[:longitude]).to include(I18n.translate('errors.messages.not_a_number')) }
    end

    context "without a unique phone" do
      let(:one_garage) { FactoryGirl.create(:garage) }
      let(:garage) { build(:garage, phone: one_garage.phone) }
      before { garage.valid? }
      subject { garage }

      it { is_expected.to_not be_valid }
      it { expect(garage.errors[:phone]).to include(I18n.translate('errors.messages.taken')) }
    end

    context "with a unique phone" do
      let(:one_garage) { FactoryGirl.create(:garage) }
      let(:garage) { build(:garage, phone: "999888777") }
      before { garage.valid? }
      subject { garage }

      it { is_expected.to be_valid }
    end

  end

end