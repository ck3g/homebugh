class Stats
  attr_reader :relation

  def initialize(relation = AggregatedTransaction)
    @relation = relation
  end

  def all
    Enumerator.new do |yielder|
      months.each do |month|
        yielder << {
          month => {
            income: @relation.income.month(month).load,
            spending:  @relation.spending.month(month).load
          }
        }
      end
    end
  end

  private
  def months
    relation.pluck(:period_started_at).uniq
  end
end
