#encoding: UTF-8
require 'rails_helper'

describe Carpark do

  describe 'when create' do
    context 'with valid data' do
      let(:carpark) { build(:carpark) }
      subject { carpark }

      it { is_expected.to be_valid }
    end

    context "with some empty attribute" do
      let(:carpark) { Carpark.new }
      before { carpark.valid? }
      subject { carpark }

      it { is_expected.to_not be_valid }
      it { expect(carpark.errors[:number]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(carpark.errors[:profit]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(carpark.errors[:user]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(carpark.errors[:garage]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(carpark.errors[:price]).to include(I18n.translate('errors.messages.blank')) }
      it { expect(carpark.errors[:reduced_price]).to include(I18n.translate('errors.messages.blank')) }
    end

    context 'carpark profit, price and reduced_price not numbers' do
      let(:carpark) { build(:carpark, price: "String", reduced_price: "String", profit: "String") }
      before { carpark.valid? }
      subject { carpark }

      it { is_expected.to_not be_valid }
      it { expect(carpark.errors[:price]).to include(I18n.translate('errors.messages.not_a_number')) }
      it { expect(carpark.errors[:reduced_price]).to include(I18n.translate('errors.messages.not_a_number')) }
      it { expect(carpark.errors[:profit]).to include(I18n.translate('errors.messages.not_a_number')) }
    end

    context 'carpark number not a number' do
      let(:carpark) { build(:carpark, number: "String") }
      before { carpark.valid? }
      subject { carpark }

      it { is_expected.to_not be_valid }
      it { expect(carpark.errors[:number]).to include(I18n.translate('errors.messages.not_a_number')) }
    end

    context "without a unique number in the same garage" do
      let(:one_carpark) { FactoryGirl.create(:carpark) }
      let(:carpark) { build(:carpark, garage: one_carpark.garage, number: one_carpark.number) }
      before { carpark.valid? }
      subject { carpark }

      it { is_expected.to_not be_valid }
      it { expect(carpark.errors[:number]).to include(I18n.translate('errors.messages.taken')) }
    end

    context "with a not unique number in different garages" do
      let(:one_carpark) { FactoryGirl.create(:carpark) }
      let(:carpark) { build(:carpark, garage: build(:garage)) }
      before { carpark.valid? }
      subject { carpark }

      it { is_expected.to be_valid }
    end

    context "carpark is valid with a unique number in the same garage" do
      let(:one_carpark) { FactoryGirl.create(:carpark) }
      let(:carpark) { build(:carpark, garage: one_carpark.garage, number: one_carpark.number + 1) }
      before { carpark.valid? }
      subject { carpark }

      it { is_expected.to be_valid }
    end

  end

end