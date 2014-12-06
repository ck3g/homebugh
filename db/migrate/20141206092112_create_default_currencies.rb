class CreateDefaultCurrencies < ActiveRecord::Migration
  def up
    {
      'MDL' => '',
      'USD' => '$',
      'EUR' => '€'
    }.each do |name, unit|
      Currency.create name: name, unit: unit
    end
  end

  def down
  end
end
