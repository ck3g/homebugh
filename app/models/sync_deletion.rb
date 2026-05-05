class SyncDeletion < ApplicationRecord
  validates :resource_type, :resource_id, :user_id, :deleted_at, presence: true

  def self.prune_older_than(duration)
    where('deleted_at < ?', duration.ago).delete_all
  end
end
