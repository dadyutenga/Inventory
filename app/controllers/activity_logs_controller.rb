class ActivityLogsController < ApplicationController
  before_action :authorize_admin!

  def index
    from_date = safe_parse_date(params[:from_date])
    to_date = safe_parse_date(params[:to_date])

    @logs = ActivityLog.includes(:user)
                       .by_user(params[:user_id])
                       .by_entity(params[:entity_type], params[:entity_id])
                       .by_action(params[:action_type])
                       .between_dates(from_date, to_date)
                       .order(created_at: :desc)
                       .limit(500)
  end

  private

  def safe_parse_date(value)
    return nil if value.blank?

    Date.parse(value)
  rescue ArgumentError
    nil
  end
end
