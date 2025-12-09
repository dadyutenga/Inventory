module ApplicationHelper
  # Format money consistently in TZS across the app
  def format_currency(amount)
    return "-" if amount.nil?

    number_to_currency(amount,
                       unit: "TZS ",
                       precision: 2,
                       delimiter: ",",
                       strip_insignificant_zeros: true)
  end
end
