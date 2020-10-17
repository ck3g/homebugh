class TotalAmount
  def self.of(user)
    user.accounts.active.show_in_summary.each_with_object(Hash.new(0)) do |account, total|
      total[account.decorate.unit] += account.funds
    end
  end
end
