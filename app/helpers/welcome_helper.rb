module WelcomeHelper
  def welcome_meta_keywords
    [
      "home finances", "finance app", "finance manager", "money manager",
      "budget", "budgeting", "money reports", "expenses", "income", "saving money",
      "home budget", "финансы", "учет финансов", "экономия денег",
      "экономия денежных средств", "учет денежных средств", "учет денег"
    ].join(",")
  end

  def welcome_meta_description
    [
      "Online finance manager for personal use.",
      "Allows to keep track of money, support several account and currencies.",
      "Helps budgeting your money and build a montly reports."
    ].join
  end
end
