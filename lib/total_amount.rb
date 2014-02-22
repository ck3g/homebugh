class TotalAmount
  def self.of(user)
    user.accounts.map(&:funds).sum
  end
end
