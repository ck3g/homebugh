require 'rails_helper'

RSpec.describe SyncDeletion do
  describe 'validations' do
    it { should validate_presence_of(:resource_type) }
    it { should validate_presence_of(:resource_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:deleted_at) }
  end

  describe '.prune_older_than' do
    let(:user) { create(:user) }

    it 'removes records older than the given duration' do
      old = SyncDeletion.create!(resource_type: 'Transaction', resource_id: 1, user_id: user.id, deleted_at: 100.days.ago)
      recent = SyncDeletion.create!(resource_type: 'Transaction', resource_id: 2, user_id: user.id, deleted_at: 10.days.ago)

      SyncDeletion.prune_older_than(90.days)

      expect(SyncDeletion.exists?(old.id)).to be false
      expect(SyncDeletion.exists?(recent.id)).to be true
    end
  end
end
