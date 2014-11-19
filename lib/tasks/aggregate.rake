namespace :aggregate do
  desc "Aggregate Transactions for whole period of time"
  task all: :environment do
    months = []
    date = 6.years.ago
    while date < 1.month.ago do
      months << date
      date += 1.month
    end

    pg = ProgressBar.create total: months.count
    months.each do |month|
      User.find_each do |user|
        ArchiveTransactionsService.new(user, month).archive
      end
      pg.increment
    end
  end
end
