module Api
  module Sync
    class PullProcessor
      RESOURCE_ASSOCIATIONS = {
        accounts: { blueprint: 'AccountBlueprint' },
        categories: { blueprint: 'CategoryBlueprint' },
        transactions: { blueprint: 'TransactionBlueprint' },
        cash_flows: { blueprint: 'CashFlowBlueprint' },
        budgets: { blueprint: 'BudgetBlueprint' },
        recurring_payments: { blueprint: 'RecurringPaymentBlueprint' },
        recurring_cash_flows: { blueprint: 'RecurringCashFlowBlueprint' }
      }.freeze

      DEFAULT_PULL_LIMIT = 200

      def initialize(user)
        @user = user
      end

      def process(last_synced_at:, exclude_ids: {}, pull_limit: DEFAULT_PULL_LIMIT)
        result = {}
        remaining = pull_limit
        cursor = nil

        RESOURCE_ASSOCIATIONS.each do |resource_type, config|
          break if remaining <= 0

          records = fetch_records(resource_type, last_synced_at, exclude_ids)
          blueprint = config[:blueprint].constantize

          batch = records.limit(remaining).to_a
          result[resource_type] = blueprint.render_as_hash(batch)
          remaining -= batch.length

          if batch.any?
            last_updated = batch.last.updated_at
            cursor = last_updated.iso8601(3) if cursor.nil? || last_updated < Time.parse(cursor)
          end
        end

        result[:deletions] = fetch_deletions(last_synced_at)

        has_more = remaining <= 0 && more_records_exist?(last_synced_at, exclude_ids, pull_limit)
        result[:has_more] = has_more
        result[:cursor] = has_more ? cursor : nil

        result
      end

      private

      def fetch_records(resource_type, last_synced_at, exclude_ids)
        association = @user.public_send(resource_type)
        association = association.updated_since(last_synced_at)

        model_name = association.klass.name
        ids_to_exclude = exclude_ids[model_name]
        association = association.where.not(id: ids_to_exclude) if ids_to_exclude.present?

        association.order(:updated_at)
      end

      def fetch_deletions(last_synced_at)
        scope = SyncDeletion.where(user_id: @user.id)
        scope = scope.where('deleted_at > ?', last_synced_at) if last_synced_at.present?

        scope.order(:deleted_at).map do |deletion|
          {
            resource_type: deletion.resource_type,
            resource_id: deletion.resource_id,
            deleted_at: deletion.deleted_at
          }
        end
      end

      def more_records_exist?(last_synced_at, exclude_ids, pull_limit)
        total = 0
        RESOURCE_ASSOCIATIONS.each do |resource_type, _|
          total += fetch_records(resource_type, last_synced_at, exclude_ids).count
        end
        total > pull_limit
      end
    end
  end
end
