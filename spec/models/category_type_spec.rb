require 'spec_helper'

describe CategoryType do
  it "income should be 1" do
    expect(CategoryType.income).to eql 1
  end

  it "spending should be 2" do
    expect(CategoryType.spending).to eql 2
  end
end