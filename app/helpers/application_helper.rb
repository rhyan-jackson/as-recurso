module ApplicationHelper
  def history_item_icon(type)
    case type
    when "payment"
      "bi-plus-lg"
    when "ride"
      "bi-bicycle"
    when "reservation"
      "bi-calendar-check"
    end
  end

  def history_item_bg_class(type)
    case type
    when "payment"
      "bg-success bg-opacity-10"
    when "ride"
      "bg-primary bg-opacity-10"
    when "reservation"
      "bg-warning bg-opacity-10"
    end
  end

  def history_item_text_class(type)
    case type
    when "payment"
      "text-success"
    when "ride"
      "text-primary"
    when "reservation"
      "text-warning"
    end
  end

  def status_badge_class(status)
    case status
    when "completed", "success", "used"
      "bg-success bg-opacity-10 text-success"
    when "cancelled", "expired"
      "bg-danger bg-opacity-10 text-danger"
    when "pending"
      "bg-warning bg-opacity-10 text-warning"
    else
      "bg-secondary bg-opacity-10 text-secondary"
    end
  end

  def status_display_text(status)
    case status
    when "completed"
      "Concluída"
    when "cancelled"
      "Cancelada"
    when "expired"
      "Expirada"
    when "used"
      "Utilizada"
    when "pending"
      "Pendente"
    else
      status.titleize
    end
  end
end
