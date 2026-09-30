module ApplicationHelper
  def get_number_to_currency(number, unit = 'лей')
    number_to_currency number, unit: unit, format: '%n %u'
  end

  # An amount with its direction shown: expenses get a real minus sign
  # (read aloud as "minus"), income is shown plain in the income colour.
  def signed_money(number, unit, income:)
    sign = income ? "" : "\u2212"
    content_tag :span, "#{sign}#{get_number_to_currency(number, unit)}",
                class: ["money", income ? "money-income" : "money-expense"]
  end

  def pending_due_label(date)
    key = date < Date.current ? 'overdue_since' : 'due_on'
    content_tag :span, t("parts.recurring_payments.#{key}", date: l(date, format: :long)),
                class: ["pending-due", ("is-overdue" if date < Date.current)]
  end

  def day_label(date)
    case date
    when Date.current then t('common.today')
    when Date.yesterday then t('common.yesterday')
    else l(date, format: :long)
    end
  end

  def inverse_locale
    is_ru? ? 'en' : 'ru'
  end

  def flash_class(name)
    css_classes = ["alert"]
    css_classes << "alert-danger" if name == 'alert'
    css_classes << "alert-success" if name == 'notice'
    css_classes.join(" ")
  end

  def copyright
    "© HomeBugh.info 2011 - #{Date.current.year}. All Rights Reserved"
  end

  def up_arrow
    content_tag :span, fa_icon('arrow-up'), class: 'text-success'
  end

  def down_arrow
    content_tag :span, fa_icon('arrow-down'), class: 'text-danger'
  end

  def active_currency?(currency, path_name, can_be_empty)
    is_active = current_page?(send(path_name, currency: currency.name))
    can_be_empty ? params[:currency].nil? || is_active : is_active
  end

  def recurring_payment_frequencies_collection
    RecurringPayment.frequencies.map { |key, _| [t("parts.recurring_payments.frequencies.#{key}"), key] }
  end

  def form_title(title)
    content_tag(:h1, title, class: 'form-title mb-4')
  end

  def new_recurring_payment_path_from(transaction)
    query_params = {
      category_id: transaction.category_id,
      account_id: transaction.account_id,
      amount: transaction.summ,
      frequency: 'monthly',
      frequency_amount: 1,
      next_payment_on: 1.month.since(transaction.created_at).to_date
    }

    new_recurring_payment_path(**query_params)
  end

  private

  def is_ru?
    I18n.locale == :ru
  end
end
