module ApplicationHelper
  def get_number_to_currency(number, unit = 'лей')
    number_to_currency number, unit: unit, format: '%n %u'
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
    "Copyright @ HomeBugh.info 2011 - #{Date.current.year}. All Rights Reserved"
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
    content_tag(:h1, title, class: 'form-title col-lg-offset-2')
  end

  def link_to_new_recurring_payment(transaction)
    query_params = {
      category_id: transaction.category_id,
      account_id: transaction.account_id,
      amount: transaction.summ,
      frequency: 'monthly',
      frequency_amount: 1,
      next_payment_on: 1.month.since(transaction.created_at).to_date
    }
    link_to new_recurring_payment_path(**query_params), class: 'btn btn-default btn-mini btn-xs btn-create-rp' do
      fa_icon 'retweet'
    end
  end

  private

  def is_ru?
    I18n.locale == :ru
  end
end
