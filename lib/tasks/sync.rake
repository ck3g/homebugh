namespace :sync do
  desc 'Prune sync_deletions older than 90 days'
  task prune_deletions: :environment do
    count = SyncDeletion.prune_older_than(90.days)
    puts "Pruned #{count} sync deletion records"
  end
end
