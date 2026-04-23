class AccountBalance
  def self.apply(record)
    new(record).apply
  end

  def self.reverse(record)
    new(record).reverse
  end

  def initialize(record)
    @record = record
  end

  def apply
    ActiveRecord::Base.transaction do
      mutations.each { |account, amount| account.deposit(amount) }
    end
  end

  def reverse
    ActiveRecord::Base.transaction do
      mutations.each { |account, amount| account.deposit(-amount) }
    end
  end

  private

  attr_reader :record

  def mutations
    case record
    when Transaction then transaction_mutations
    when CashFlow then cash_flow_mutations
    else raise ArgumentError, "Unknown record type: #{record.class}"
    end
  end

  def transaction_mutations
    signed_amount = record.income? ? record.summ : -record.summ
    [[record.account, signed_amount]]
  end

  def cash_flow_mutations
    withdrawal_amount = record.initial_amount.presence || record.amount
    [
      [record.from_account, -withdrawal_amount],
      [record.to_account, record.amount]
    ]
  end
end
