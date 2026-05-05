class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :updated_since, ->(timestamp) { where('updated_at > ?', timestamp) if timestamp.present? }
end
