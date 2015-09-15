class TransactionsController < ApplicationController
  rescue_from Paypal::Exception::APIError, with: :paypal_api_error

  before_filter :authenticate_user!, :except => [:show_pending_withdraw_balance, :dispatch_pending_withdraw_balance]
  before_filter :authenticate_admin!, only: [:show_pending_withdraw_balance, :dispatch_pending_withdraw_balance]

  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.where("user_id = ?", current_user.id)
  end

  # GET /transactions/new
  # GET /transactions/new.xml
  def new
    @transaction = current_user.transactions.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    @transaction = current_user.transactions.build(amount: transaction_params[:amount])
    @transaction.movement_type = :top_up

    if @transaction.valid?
      @transaction.ip_address = request.remote_ip

      @transaction.setup!(
          success_transactions_url,
          cancel_transactions_url
      )
    end

    respond_to do |format|
      if @transaction.valid?
        format.html { redirect_to @transaction.redirect_uri }
        #format.xml  { render :xml => @rent, :status => :created, :location => @rent }
      else
        format.html { render :action => "new" }
        #format.xml  { render :xml => @rent.errors, :status => :unprocessable_entity }
      end
    end
  end

  def success
    handle_callback do |transaction|
      transaction.complete!(params[:PayerID])
      flash[:notice] = I18n.t('activerecord.messages.transaction.transaction_completed')
      transactions_path
    end
  end

  def cancel
    handle_callback do |transaction|
      transaction.cancel!
      flash[:warn] = I18n.t('activerecord.messages.transaction.transaction_canceled')
      root_url
    end
  end

  # GET /transactions/withdraw_balance
  # GET /transactions/withdraw_balance.xml
  def withdraw_balance
    @transaction = current_user.transactions.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # POST /transactions
  # POST /transactions.xml
  def withdraw_balance_create
    @transaction = current_user.transactions.build(amount: transaction_params[:amount],
                                                   ip_address: request.remote_ip,
                                                   status: 'Pending',
                                                   description: I18n.t('activerecord.messages.transaction.withdraw_balance_description', :amount => (transaction_params[:amount])))

    # ViewHelper::number_to_euros

    @transaction.movement_type = :withdraw

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to(transactions_path, :notice => I18n.t('text.general.successfully_created', name:  I18n.t('text.transaction.withdraw'))) }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "withdraw_balance" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /show_pending_withdraw_balance/1
  # GET /show_pending_withdraw_balance/1.xml
  def show_pending_withdraw_balance
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show_pending_withdraw_balance.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  def dispatch_pending_withdraw_balance
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.dispatch
        format.html { redirect_to(show_pending_withdraw_balance_transaction_path(@transaction), :notice => I18n.t('text.transaction.withdraw_balance_dispatched')) }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => 'show_pending_withdraw_balance' }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def handle_callback
    transaction = Transaction.find_by_token! params[:token]
    @redirect_uri = yield transaction
    redirect_to @redirect_uri
  end

  def paypal_api_error(e)
    redirect_to root_url, error: e.response.details.collect(&:long_message).join('<br />')
  end

  def set_transaction
    @transaction = Transaction.find(transaction_params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:id, :amount, :token)
  end

  def owner!
    if @transaction.user != current_user
      redirect_to(root_url, :notice => I18n.t('text.general.unauthorized'))
    end
  end
end
