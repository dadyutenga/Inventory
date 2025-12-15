class BlacklistedToken < ApplicationRecord
  self.primary_key = "id"

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Blacklist a token
  def self.blacklist(token, expires_at)
    digest = Digest::SHA256.hexdigest(token)
    create!(token_digest: digest, expires_at: expires_at)
  rescue ActiveRecord::RecordNotUnique
    # Token already blacklisted, ignore
    true
  end

  # Check if a token is blacklisted
  def self.blacklisted?(token)
    digest = Digest::SHA256.hexdigest(token)
    exists?(token_digest: digest)
  end

  # Clean up expired tokens (call this periodically)
  def self.cleanup_expired
    where("expires_at < ?", Time.current).delete_all
  end
end
