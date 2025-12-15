class ActivityLog < ApplicationRecord
  self.primary_key = "id"

  belongs_to :user

  validates :action_type, :entity_type, :entity_id, :user_id, presence: true

  scope :by_user, ->(user_id) { where(user_id: user_id) if user_id.present? }
  scope :by_entity, ->(entity_type, entity_id = nil) {
    if entity_type.present? && entity_id.present?
      where(entity_type: entity_type, entity_id: entity_id)
    elsif entity_type.present?
      where(entity_type: entity_type)
    else
      all
    end
  }
  scope :by_action, ->(action_type) { where(action_type: action_type) if action_type.present? }
  scope :between_dates, ->(from_date, to_date) {
    scope = all
    scope = scope.where("created_at >= ?", from_date.beginning_of_day) if from_date.present?
    scope = scope.where("created_at <= ?", to_date.end_of_day) if to_date.present?
    scope
  }

  def self.log!(user:, action_type:, record:, old_values: nil, new_values: nil, ip_address: nil, user_agent: nil)
    create!(
      user: user,
      action_type: action_type,
      entity_type: record.class.name,
      entity_id: record.id,
      old_values: old_values,
      new_values: new_values,
      ip_address: ip_address,
      user_agent: user_agent
    )
  end
end
