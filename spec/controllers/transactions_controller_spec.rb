require 'rails_helper'

describe TransactionsController, :type => :controller do

  describe 'guess access' do

    before(:each) do
      # sign_in nil
      @rent = create(:rent)
    end

    describe 'GET #index' do
      it 'requires login' do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'user access' do

    before(:each) do
      @user = create(:user)
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
    end

    describe "GET#index" do
      before {
        @transactions = Array.new
        @transactions.push(create(:transaction, user: @user))
        @transactions.push(create(:transaction, user: @user))
        get :index
      }

      it 'populates an array of transactions' do
        expect(assigns(:transactions)).to match_array @transactions.to_a
      end

      it 'render the :index template' do
        expect(response).to render_template :index
      end
    end

    describe 'GET #new' do
      before {
        @transaction = create(:transaction, user: @user)
        get :new, id: @transaction
      }

      it "assigns a new Transaction to @transaction" do
        expect(assigns(:transaction)).to be_a_new Transaction
      end

      it 'renders the :show template' do
        expect(response).to render_template :new
      end
    end

    describe "POST #create" do
      before {
        FakeWeb.allow_net_connect = false
        FakeWeb.clean_registry

        FakeWeb.register_uri(:post,
                  Paypal::NVP::Request.endpoint,
                  :body => "TOKEN=EC-9E2743126S4330617&SUCCESSPAGEREDIRECTREQUESTED=false&TIMESTAMP=2011-02-08T03:23:55Z&CORRELATIONID=15b93874c358c&ACK=Success&VERSION=66.0&BUILD=1721431&INSURANCEOPTIONSELECTED=false&SHIPPINGOPTIONISDEFAULT=false&PAYMENTINFO_0_TRANSACTIONID=8NC65222871997739&PAYMENTINFO_0_TRANSACTIONTYPE=expresscheckout&PAYMENTINFO_0_PAYMENTTYPE=instant&PAYMENTINFO_0_ORDERTIME=2011-02-08T03:23:54Z&PAYMENTINFO_0_AMT=14.00&PAYMENTINFO_0_FEEAMT=0.85&PAYMENTINFO_0_TAXAMT=0.00&PAYMENTINFO_0_CURRENCYCODE=USD&PAYMENTINFO_0_PAYMENTSTATUS=Completed&PAYMENTINFO_0_PENDINGREASON=None&PAYMENTINFO_0_REASONCODE=None&PAYMENTINFO_0_PROTECTIONELIGIBILITY=Ineligible&PAYMENTINFO_0_PROTECTIONELIGIBILITYTYPE=None&PAYMENTINFO_0_ERRORCODE=0&PAYMENTINFO_0_ACK=Success"
          )}

      context "with valid attributes" do
        it 'saves the new transaction in the database' do
          expect { post :create, transaction: attributes_for(:transaction) }.to change(Transaction, :count).by(1)
        end
        it 'redirects to transactions#show' do
          post :create, transaction: attributes_for(:transaction)
          expect(response.location).to match('https://www.sandbox.paypal.com/')
        end
      end
    end

    describe 'GET #withdraw_balance' do
      before {
        @withdraw = create(:withdraw, user: @user)
        get :withdraw_balance, id: @withdraw
      }

      it "assigns a new Transaction to @transaction" do
        expect(assigns(:transaction)).to be_a_new Transaction
      end

      it 'renders the :show template' do
        expect(response).to render_template :withdraw_balance
      end
    end

    describe "POST #withdraw_balance_create" do
      context "with valid attributes" do
        it 'saves the new transaction in the database' do
          expect { post :withdraw_balance_create, transaction: attributes_for(:withdraw) }.to change(Transaction, :count).by(1)
        end
        it 'redirects to transactions#show' do
          post :withdraw_balance_create, transaction: attributes_for(:withdraw)
          expect(response).to redirect_to transactions_path
        end
      end
      context "with invalid attributes" do
        # it "does not save the new contact in the database"
        # it "re-renders the :new template"
      end
    end

    describe 'GET #success' do
      # it "assigns a new Transaction to @transaction"
      # it "renders the :wtihdraw_balance template"
    end

    describe 'GET #cancel' do
      # it "assigns a new Transaction to @transaction"
      # it "renders the :wtihdraw_balance template"
    end

    describe 'GET #show_pending_withdraw_balance' do
      before {
        @withdraw = create(:withdraw)
      }

      it 'requires admin login' do
        get :show_pending_withdraw_balance, id: @withdraw
        expect(response).to redirect_to new_admin_session_path
      end
    end


    describe "POST #dispatch_withdraw_balance_create" do
      before {
        @withdraw = create(:withdraw)
      }

      it 'requires admin login' do
        post :dispatch_pending_withdraw_balance, id: @withdraw
        expect(response).to redirect_to new_admin_session_path
      end
    end

  end

  describe 'admin access' do

    let(:transaction) { create(:withdraw) }

    before(:each) do
      @admin = create(:admin)
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      sign_in @admin
      transaction
    end

    describe 'GET #show_pending_withdraw_balance' do

      it 'assigns the requested transaction to @transaction' do
        get :show_pending_withdraw_balance, id: transaction
        expect(assigns(transaction)).to eq @transaction
      end

      it "renders the :show template" do
        get :show_pending_withdraw_balance, id: transaction
        expect(response).to render_template :show_pending_withdraw_balance
      end

      context 'transaction not exist' do
        it 'response 404' do
          get :show_pending_withdraw_balance, id: 'notexist'
          expect(response.status).to eq 404
        end

        it 'renders error page' do
          get :show_pending_withdraw_balance, id: 'notexist'
          expect(response).to render_template(:file => "#{Rails.root}/public/404.html")
        end
      end
    end

    describe "POST #dispatch_withdraw_balance_create" do
      before {
          @withdraw = create(:withdraw)
      }

      it "locates the requested @withdraw" do
        post :dispatch_pending_withdraw_balance, id: @withdraw
        expect(assigns(:transaction)).to eq(@withdraw)
      end

      it 'update the transaction in the database' do
        post :dispatch_pending_withdraw_balance, id: @withdraw
        @withdraw.reload
        expect(@withdraw.status).to eq('Completed')
      end

      it "show success message" do
        post :dispatch_pending_withdraw_balance, id: @withdraw
        expect(flash[:notice]).to eq I18n.t('text.transaction.withdraw_balance_dispatched')
      end

      it 'redirects to withdraw_balance#show' do
        post :dispatch_pending_withdraw_balance, id: @withdraw
        expect(response).to redirect_to show_pending_withdraw_balance_transaction_path(assigns[:transaction])
      end
    end
  end

end