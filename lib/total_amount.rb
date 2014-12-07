class TotalAmount
  def self.of(user)
    amount = {}
    user.accounts.each do |account|
      key = account.decorate.unit
      if amount.has_key? account.decorate.unit
        amount[key] += account.funds
      else
        amount[key] = account.funds
      end
    end

    amount
  end
end
