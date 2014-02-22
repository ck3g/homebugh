module ApplicationHelper
  def get_number_to_currency number
    number_to_currency number, unit: 'лей', format: '%n %u'
  end

  def inverse_locale
    is_ru? ? 'en' : 'ru'
  end

  def flash_class(name)
    css_classes = ["alert"]
    css_classes << " alert-danger" if name == :alert
    css_classes << " alert-success" if name == :notice
    css_classes.join(" ")
  end

  private
  def is_ru?
    I18n.locale == :ru
  end
end
