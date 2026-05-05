require 'rails_helper'

RSpec.describe ApplicationRecord do
  describe '.updated_since' do
    let(:user) { create(:user) }

    it 'returns records updated after the given timestamp' do
      old_currency = create(:currency, name: 'Old')
      old_currency.update_column(:updated_at, 2.days.ago)

      new_currency = create(:currency, name: 'New')
      new_currency.update_column(:updated_at, 1.hour.ago)

      result = Currency.updated_since(1.day.ago.iso8601)

      expect(result).to include(new_currency)
      expect(result).not_to include(old_currency)
    end

    it 'returns all records when timestamp is nil' do
      currency = create(:currency)

      result = Currency.updated_since(nil)

      expect(result).to include(currency)
    end

    it 'returns all records when timestamp is blank' do
      currency = create(:currency)

      result = Currency.updated_since('')

      expect(result).to include(currency)
    end
  end
end
