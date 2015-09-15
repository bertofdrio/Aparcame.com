#encoding: UTF-8
require 'rails_helper'

describe User do

  describe 'when create' do
    context 'with an invalid email' do
      let(:user) { build(:user, email: 'notvalid', confirmed_at: nil) }
      before { user.valid? }
      subject { user }
      it { is_expected.to_not be_valid }
      it { expect(user.errors[:email]).to include('invalid') }
    end

    context 'with not unique email' do
      let(:user) { build(:user, email: @user.email, confirmed_at: nil) }
      before(:each) do
        @user = create(:user)
        user.valid?
      end
      subject { user }

      it { is_expected.to_not be_valid }
      it { expect(user.errors[:email]).to include(I18n.t('errors.messages.taken')) }
    end

    context 'with invalid DNI' do
      let(:user) { build(:user, dni: '12345678Q') }
      before { user.valid? }
      subject { user }

      it { is_expected.to_not be_valid }
      it { expect(user.errors[:dni]).to include('invalid') }
    end

    context 'with invalid phone' do
      let(:user) { build(:user, phone: '123456') }
      before { user.valid? }
      subject { user }

      it { is_expected.to_not be_valid }
      it { expect(user.errors[:phone]).to include('invalid') }
    end

    context 'with invalid license' do
      let(:user) { build(:user, license: '111-RRR') }
      before { user.valid? }
      subject { user }

      it { is_expected.to_not be_valid }
      it { expect(user.errors[:license]).to include('invalid') }
    end

    context 'with invalid name' do
      let(:user) { build(:user, name: 'Este es un nombre demasiado largo y no debería ser válido') }
      before { user.valid? }
      subject { user }

      it { is_expected.to_not be_valid }
      it { expect(user.errors[:name]).to include(I18n.t('errors.messages.too_long.other', count: 50)) }
    end

    context 'with invalid surname' do
      let(:user) { build(:user, surname: 'Este es un apellido demasiado largo y no debería ser válido') }
      before { user.valid? }
      subject { user }

      it { is_expected.to_not be_valid }
      it { expect(user.errors[:surname]).to include(I18n.t('errors.messages.too_long.other', count: 50)) }
    end

    context 'with valid data' do
      let(:user) { build(:user, dni: '11223344B', phone: '123456789', license: '1111-AAA',
                         name: 'Juan',
                         surname: 'González') }
      subject { user }

      it { is_expected.to be_valid }
    end
  end

  describe 'when update balance' do

    before { @user = create(:user, balance: 100) }

    it 'is invalid if result is than 0' do
      # @user.balance = -1
      # @user.valid?
      # expect(@user.errors.count).to eq(1)
    end

    it 'is valid if result is greater or equal than 0' do
      @user.update_balance(10)
      @user.valid?
      expect(@user).to be_valid
    end

  end

  describe 'when get #not_commited_balance' do
    let(:user) { build(:user, balance: BigDecimal(10, 2)) }
    let(:booking) { create(:booking, user: user) }
    subject(:balance) { user.not_committed_balance }

    context 'without bookings not paid' do
      it { is_expected.to eq BigDecimal(10, 2) }
    end

    context 'with bookings not paid' do
      before{ @booking_time = create(:booking_time_with_availability, booking: booking) }
      it { is_expected.to eq (BigDecimal(10, 2) - @booking_time.total_amount) }
    end



  end
end