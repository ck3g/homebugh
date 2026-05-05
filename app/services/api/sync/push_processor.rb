module Api
  module Sync
    class PushProcessor
      RESOURCE_CONFIG = {
        'categories' => {
          model: 'Category',
          create_params: %w[name category_type_id client_uuid],
          update_params: %w[name inactive]
        },
        'accounts' => {
          model: 'Account',
          create_params: %w[name currency_id show_in_summary client_uuid],
          update_params: %w[name show_in_summary]
        },
        'transactions' => {
          model: 'Transaction',
          create_params: %w[account_id category_id comment client_uuid],
          update_params: %w[comment],
          amount_field: 'summ'
        },
        'cash_flows' => {
          model: 'CashFlow',
          create_params: %w[amount initial_amount from_account_id to_account_id client_uuid],
          update_params: []
        },
        'budgets' => {
          model: 'Budget',
          create_params: %w[category_id currency_id limit client_uuid],
          update_params: %w[limit category_id currency_id]
        },
        'recurring_payments' => {
          model: 'RecurringPayment',
          create_params: %w[title amount account_id category_id frequency frequency_amount next_payment_on ends_on client_uuid],
          update_params: %w[title amount account_id category_id frequency frequency_amount next_payment_on ends_on]
        },
        'recurring_cash_flows' => {
          model: 'RecurringCashFlow',
          create_params: %w[amount from_account_id to_account_id frequency frequency_amount next_transfer_on ends_on client_uuid],
          update_params: %w[amount from_account_id to_account_id frequency frequency_amount next_transfer_on ends_on]
        }
      }.freeze

      attr_reader :pushed_record_ids

      def initialize(user)
        @user = user
        @pushed_record_ids = {}
      end

      def process(changes)
        results = {}

        changes.each do |resource_type, operations|
          config = RESOURCE_CONFIG[resource_type]
          next unless config

          results[resource_type.to_sym] = {
            created: [],
            updated: [],
            deleted: [],
            rejected: []
          }

          process_creates(resource_type, operations['created'] || [], config, results)
          process_updates(resource_type, operations['updated'] || [], config, results)
          process_deletes(resource_type, operations['deleted'] || [], config, results)
        end

        results
      end

      private

      def process_creates(resource_type, items, config, results)
        model_class = config[:model].constantize
        association = association_for(resource_type)

        items.each do |item|
          client_uuid = item['client_uuid']

          # Idempotency: check for existing client_uuid
          if client_uuid.present?
            existing = association.find_by(client_uuid: client_uuid)
            if existing
              track_pushed_id(config[:model], existing.id)
              results[resource_type.to_sym][:created] << { client_uuid: client_uuid, server_id: existing.id, status: 'ok' }
              next
            end
          end

          attrs = extract_create_attrs(item, config)
          record = association.new(attrs)

          if record.save
            track_pushed_id(config[:model], record.id)
            results[resource_type.to_sym][:created] << { client_uuid: client_uuid, server_id: record.id, status: 'ok' }
          else
            results[resource_type.to_sym][:rejected] << {
              client_uuid: client_uuid,
              operation: 'create',
              reason: record.errors.full_messages.join(', ')
            }
          end
        end
      end

      def process_updates(resource_type, items, config, results)
        association = association_for(resource_type)

        items.each do |item|
          record = association.find_by(id: item['id'])
          unless record
            results[resource_type.to_sym][:rejected] << { id: item['id'], operation: 'update', reason: 'Not found' }
            next
          end

          # Last-write-wins
          ios_updated_at = Time.parse(item['updated_at']) if item['updated_at'].present?
          if ios_updated_at && record.updated_at > ios_updated_at
            results[resource_type.to_sym][:updated] << { id: record.id, status: 'skipped' }
            next
          end

          attrs = extract_update_attrs(item, config)
          if record.update(attrs)
            track_pushed_id(config[:model], record.id)
            results[resource_type.to_sym][:updated] << { id: record.id, status: 'ok' }
          else
            results[resource_type.to_sym][:rejected] << {
              id: record.id,
              operation: 'update',
              reason: record.errors.full_messages.join(', ')
            }
          end
        end
      end

      def process_deletes(resource_type, items, config, results)
        association = association_for(resource_type)

        items.each do |item|
          record = association.find_by(id: item['id'])
          unless record
            results[resource_type.to_sym][:deleted] << { id: item['id'], status: 'ok' }
            next
          end

          record.destroy

          if record_deleted?(record)
            results[resource_type.to_sym][:deleted] << { id: item['id'], status: 'ok' }
          else
            results[resource_type.to_sym][:rejected] << {
              id: item['id'],
              operation: 'delete',
              reason: deletion_failure_reason(record)
            }
          end
        end
      end

      def association_for(resource_type)
        case resource_type
        when 'categories' then @user.categories
        when 'accounts' then @user.accounts
        when 'transactions' then @user.transactions
        when 'cash_flows' then @user.cash_flows
        when 'budgets' then @user.budgets
        when 'recurring_payments' then @user.recurring_payments
        when 'recurring_cash_flows' then @user.recurring_cash_flows
        end
      end

      def extract_create_attrs(item, config)
        attrs = item.slice(*config[:create_params])
        # Map 'amount' to 'summ' for transactions
        if config[:amount_field] && item['amount'].present?
          attrs[config[:amount_field]] = item['amount']
        end
        attrs
      end

      def extract_update_attrs(item, config)
        item.slice(*config[:update_params])
      end

      def record_deleted?(record)
        if record.respond_to?(:deleted?) && record.respond_to?(:aasm)
          record.deleted?
        else
          !record.persisted? || record.destroyed?
        end
      end

      def deletion_failure_reason(record)
        if record.errors.any?
          record.errors.full_messages.join(', ')
        else
          'Could not delete'
        end
      end

      def track_pushed_id(model_name, id)
        @pushed_record_ids[model_name] ||= []
        @pushed_record_ids[model_name] << id
      end
    end
  end
end
