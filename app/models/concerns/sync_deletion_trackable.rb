module SyncDeletionTrackable
  extend ActiveSupport::Concern

  included do
    after_destroy :record_sync_deletion, if: :actually_destroyed?
  end

  private

  def record_sync_deletion
    SyncDeletion.create!(
      resource_type: self.class.name,
      resource_id: id,
      user_id: user_id,
      deleted_at: Time.current
    )
  end

  def actually_destroyed?
    !persisted? || destroyed?
  end
end
