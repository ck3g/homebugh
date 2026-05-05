module Api
  class SyncService
    def initialize(user)
      @user = user
    end

    def call(last_synced_at:, changes: {})
      pushed = {}
      pushed_record_ids = {}

      if changes.present?
        push_processor = Api::Sync::PushProcessor.new(@user)
        pushed = push_processor.process(changes)
        pushed_record_ids = push_processor.pushed_record_ids
      end

      pull_processor = Api::Sync::PullProcessor.new(@user)
      pull = pull_processor.process(
        last_synced_at: last_synced_at,
        exclude_ids: pushed_record_ids
      )

      { pushed: pushed, pull: pull }
    end
  end
end
