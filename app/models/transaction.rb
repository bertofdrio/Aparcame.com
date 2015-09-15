class Transaction < ActiveRecord::Base
  enum movement_type: { top_up: 0, withdraw: 1 }

  belongs_to :user

  validates :token, uniqueness: true, if: Proc.new { |transaction| transaction.top_up? }, :on => :update
  validates_presence_of :amount, :user
  validates_presence_of :token, if: Proc.new { |transaction| transaction.top_up? }, :on => :update
  validates_numericality_of :amount, :greater_than_or_equal_to => 10
  validate :validate_balance, if: Proc.new { |transaction| !transaction.user.nil? && transaction.withdraw? && transaction.status != 'Completed'}

  attr_reader :redirect_uri
  def setup!(return_url, cancel_url)
    response = client.setup(
        payment_request,
        return_url,
        cancel_url,
        pay_on_paypal: true,
        no_shipping: true
    )
    self.token = response.token
    self.save!
    @redirect_uri = response.redirect_uri
    self
  end

  def cancel!
    self.status = "Cancelled"
    self.save!
    self
  end

  def complete!(payer_id = nil)
    response = client.checkout!(self.token, payer_id, payment_request)

    if response.ack == 'Success'
      begin
        self.payer_id = payer_id
        self.transaction_id = response.payment_info.first.transaction_id
        self.transaction_type = response.payment_info.first.transaction_type
        self.fee = response.payment_info.first.amount.fee
        self.status  = response.payment_info.first.payment_status
        self.description = payment_request.description

        self.deposit
      rescue => e
        self.status = 'Failed'
        raise
      ensure
        self.save
      end
    end

    self
  end

  def deposit
    self.user.update_balance(self.amount)
  end

  def dispatch
    success =  false
    if self.top_up? || self.status == 'Completed'
      errors.add(:base, I18n.t('activerecord.errors.models.transaction.cannot_withdraw'))
      return false
    end

    Transaction.transaction do
      begin
        self.user.update_balance(-self.amount)
        self.status = 'Completed'
        success = true
      rescue Exception => e
        puts e.message
        self.status = 'Failed'
        success = false
      ensure
        self.save
      end
    end

    return success
  end

  private

  def client
    Paypal::Express::Request.new PAYPAL_CONFIG
  end

  def payment_request
    request_attributes = item = {
                               name: I18n.t('activerecord.messages.transaction.reload_balance_description'),
                               description: I18n.t('activerecord.messages.transaction.reload_balance_description', :amount => (self.amount)),
                               amount: self.amount,
                               currency_code: :EUR
                           }

    Paypal::Payment::Request.new request_attributes
  end

  def validate_balance
    errors.add(:amount, I18n.t('activerecord.errors.models.transaction.not_enough_balance')) unless self.user.not_committed_balance >= self.amount
  end
end
