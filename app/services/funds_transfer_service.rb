class FundsTransferService
  attr_reader :source, :destination

  def initialize(source, destination)
    @source = source
    @destination = destination
  end

  def transfer(initial_amount, amount)
    ActiveRecord::Base.transaction do
      source.withdrawal initial_amount
      destination.deposit amount
    end
  end
end
