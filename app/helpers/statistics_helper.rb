module StatisticsHelper

  def percent_of current, total
    "%.2f" % (current.to_f / total.to_f * 100)
  end

end
