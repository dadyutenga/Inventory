# Configure Rails to use UUIDs as default primary keys
Rails.application.configure do
  config.generators do |g|
    g.orm :active_record, primary_key_type: :uuid
  end
end

# Set UUID as default primary key for new models
Rails.application.config.active_record.primary_key = :uuid
