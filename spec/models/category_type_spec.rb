require 'spec_helper'

describe CategoryType do
  it "income should be 1" do
    CategoryType.income.should eql 1
  end

  it "spending should be 2" do
    CategoryType.spending.should eql 2
  end
end