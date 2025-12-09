class ActivityLogger
  def self.log(user:, action_type:, record:, old_values: nil, new_values: nil, request: nil)
    return unless user && record

    ActivityLog.log!(
      user: user,
      action_type: action_type,
      record: record,
      old_values: compact_values(old_values),
      new_values: compact_values(new_values),
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  rescue StandardError => e
    Rails.logger.error("Activity logging failed: #{e.message}")
  end

  def self.compact_values(values)
    return nil if values.nil?
    return values unless values.respond_to?(:compact)

    values.compact
  end
  private_class_method :compact_values
end
