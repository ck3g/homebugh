# AuthSession holds API session data
class AuthSession < ApplicationRecord
  belongs_to :user

  validates :user, :expired_at, presence: true
  validates :token, presence: true, uniqueness: { case_sensitive: true }
end
