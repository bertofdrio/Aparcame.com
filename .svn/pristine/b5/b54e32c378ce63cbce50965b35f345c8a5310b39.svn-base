require 'rails_helper'

describe Transaction do

  it "is invalid if has not user" do
    transaction = FactoryGirl.build(:transaction, user: nil)

    expect(transaction).to_not be_valid
    expect(transaction.errors[:user]).to include(I18n.translate('errors.messages.blank'))
  end

  describe "type topup" do

    it "is invalid if amount es less than 10" do
      transaction = FactoryGirl.build(:transaction, amount: 9)

      expect(transaction).to_not be_valid
      expect(transaction.errors[:amount]).to include(I18n.translate('errors.messages.greater_than_or_equal_to', count: 10))
    end

    it "is invalid if token is empty" do
      transaction = FactoryGirl.build(:transaction, token: nil)
      transaction.save!

      expect(transaction).to_not be_valid
      expect(transaction.errors[:token]).to include(I18n.translate('errors.messages.blank', count: 10))
    end

    it "is invalid if token is not unique" do
      user = FactoryGirl.create(:user)
      FactoryGirl.create(:transaction, token: 'ABCD', user: user)
      transaction = FactoryGirl.build(:transaction, token: 'ABCD', user: user)
      transaction.save!

      expect(transaction).to_not be_valid
      expect(transaction.errors[:token]).to include(I18n.t('errors.messages.taken'))
    end

    it "is valid if amount es greater or equal than 10, has a unique token and a user" do
      expect(FactoryGirl.build(:transaction)).to be_valid
    end

    describe "operations" do
      before(:each) do
        FakeWeb.allow_net_connect = false
        FakeWeb.clean_registry

        FakeWeb.register_uri(
            :post,
            Paypal::NVP::Request.endpoint,
            :body => "ACK=Success&BUILD=1721431&CORRELATIONID=5549ea3a78af1&TIMESTAMP=2011-02-02T02%3A02%3A18Z&TOKEN=EC-5YJ90598G69065317&VERSION=66.0"
        )
        @transaction = FactoryGirl.build(:transaction)
        @transaction.setup! "http://example.com", "http://example.com"
      end

      it "the status is cancelled if cancel" do
        FakeWeb.register_uri(
            :post,
            Paypal::NVP::Request.endpoint,
            :body => "TIMESTAMP=2011%2d02%2d08T07%3a15%3a19Z&CORRELATIONID=5dd0308345382&ACK=Failure&VERSION=66%2e0&BUILD=1721431&L_ERRORCODE0=10410&L_SHORTMESSAGE0=Invalid%20token&L_LONGMESSAGE0=Invalid%20token%2e&L_SEVERITYCODE0=Error"
        )
        @transaction.cancel!
        expect(@transaction.status).to eq("Cancelled")
      end

      it "the status is completed and balance has increase if complete" do
        # FakeWeb.register_uri(:any, transaction.redirect_uri, :body => "Paid")
        # response = nil
        # uri = URI(transaction.redirect_uri)
        # Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        #   request = Net::HTTP::Get.new uri.request_uri
        #   response = http.request request # Net::HTTPResponse object
        # end

        FakeWeb.register_uri(
            :post,
            Paypal::NVP::Request.endpoint,
            :body => "TOKEN=EC-9E2743126S4330617&SUCCESSPAGEREDIRECTREQUESTED=false&TIMESTAMP=2011-02-08T03:23:55Z&CORRELATIONID=15b93874c358c&ACK=Success&VERSION=66.0&BUILD=1721431&INSURANCEOPTIONSELECTED=false&SHIPPINGOPTIONISDEFAULT=false&PAYMENTINFO_0_TRANSACTIONID=8NC65222871997739&PAYMENTINFO_0_TRANSACTIONTYPE=expresscheckout&PAYMENTINFO_0_PAYMENTTYPE=instant&PAYMENTINFO_0_ORDERTIME=2011-02-08T03:23:54Z&PAYMENTINFO_0_AMT=14.00&PAYMENTINFO_0_FEEAMT=0.85&PAYMENTINFO_0_TAXAMT=0.00&PAYMENTINFO_0_CURRENCYCODE=USD&PAYMENTINFO_0_PAYMENTSTATUS=Completed&PAYMENTINFO_0_PENDINGREASON=None&PAYMENTINFO_0_REASONCODE=None&PAYMENTINFO_0_PROTECTIONELIGIBILITY=Ineligible&PAYMENTINFO_0_PROTECTIONELIGIBILITYTYPE=None&PAYMENTINFO_0_ERRORCODE=0&PAYMENTINFO_0_ACK=Success"
        )

        expect { @transaction.complete!("ZSDHVTZVBC99L") }.to change { @transaction.user.balance }.by(BigDecimal(10, 2))
        expect(@transaction.status).to eq("Completed")
      end

    end
  end

  describe "type withdraw" do

    it 'is invalid withdraw if amount is less than 10' do
      transaction = FactoryGirl.build(:withdraw, amount: 9)

      expect(transaction).to_not be_valid
      expect(transaction.errors[:amount]).to include(I18n.translate('errors.messages.greater_than_or_equal_to', count: 10))
    end

    it 'is invalid withdraw if amount is greater than not committed balance' do
      transaction = FactoryGirl.build(:withdraw, amount: 12)
      transaction.user.balance = 11
      transaction.user.save

      expect(transaction).to_not be_valid
      expect(transaction.errors[:amount]).to include(I18n.translate('activerecord.errors.models.transaction.not_enough_balance'))
    end

    it 'is invalid withdraw if amount is greater than balance (without committed balance)' do
      transaction = FactoryGirl.build(:withdraw, amount: 12)
      bookings = FactoryGirl.create(:booking_next_month, user: transaction.user)

      transaction.user.balance = 11 + bookings.total_amount
      transaction.user.save

      expect(transaction).to_not be_valid
      expect(transaction.errors[:amount]).to include(I18n.translate('activerecord.errors.models.transaction.not_enough_balance'))
    end

    it 'is valid if is pending, user has enough balance and amount is greater or equal than 10' do
      expect(FactoryGirl.build(:withdraw)).to be_valid
    end

    describe "operations" do
      it 'is invalid dispatch a top_up' do
        transaction = FactoryGirl.build(:transaction)
        expect(transaction.dispatch).to be_falsey
        expect(transaction.errors[:base]).to include(I18n.translate('activerecord.errors.models.transaction.cannot_withdraw'))
      end

      it 'is invalid dispatch a withdraw completed' do
        transaction = FactoryGirl.build(:withdraw, status: "Completed")
        expect(transaction.dispatch).to be_falsey
        expect(transaction.errors[:base]).to include(I18n.translate('activerecord.errors.models.transaction.cannot_withdraw'))
      end

      it 'the status is completed and the balance decrease if dispatch' do
        transaction = FactoryGirl.build(:withdraw)
        expect(transaction.dispatch).to be_truthy
        expect(transaction.user.balance).to eq(BigDecimal(90, 2))
      end
    end

  end
end