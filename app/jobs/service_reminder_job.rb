class ServiceReminderJob < ApplicationJob
  queue_as :default

  def perform
    # Find laptops that need service within the next 7 days
    laptops_needing_service = Laptop.where("next_service_due BETWEEN ? AND ?",
                                           Date.current,
                                           7.days.from_now)
                                    .where.not(status: [ :sold, :retired ])

    laptops_needing_service.each do |laptop|
      # Broadcast service alert via Action Cable
      ActionCable.server.broadcast(
        "alerts",
        {
          type: "service_reminder",
          laptop_id: laptop.id,
          laptop_name: laptop.display_name,
          service_due: laptop.next_service_due.strftime("%B %d, %Y"),
          message: "#{laptop.display_name} needs service on #{laptop.next_service_due.strftime('%B %d, %Y')}"
        }
      )
    end

    Rails.logger.info "Sent service reminders for #{laptops_needing_service.count} laptops"
  end
end
