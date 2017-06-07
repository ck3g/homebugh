module Orderable
  extend ActiveSupport::Concern

  included do
    scope :by_recently_used, -> { order(updated_at: :desc) }
  end
end
