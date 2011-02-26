class Transaction < ActiveRecord::Base
	belongs_to :category
  
  validates_presence_of :summ
  validates_numericality_of :summ
  validate :sum_cannot_be_less_than_0_01, :unless => 'summ.nil?'
  
  def sum_cannot_be_less_than_0_01
    errors.add( :summ, I18n.t( 'common.cannot_be_less_than', :value => 0.01 ) ) if (summ < 0.01)
  end
  
end
