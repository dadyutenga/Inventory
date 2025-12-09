namespace :tokens do
  desc "Clean up expired blacklisted tokens"
  task cleanup: :environment do
    count = BlacklistedToken.cleanup_expired
    puts "Cleaned up #{count} expired blacklisted tokens"
  end
end
