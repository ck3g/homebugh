module ApplicationHelper
  def get_number_to_currency(number, unit = 'лей')
    number_to_currency number, unit: unit, format: '%n %u'
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

  def copyright
    "copyright @2011 - #{Date.current.year}"
  end

  def up_arrow
    content_tag :span, fa_icon('arrow-up'), class: 'text-success'
  end

  def down_arrow
    content_tag :span, fa_icon('arrow-down'), class: 'text-danger'
  end

  private
  def is_ru?
    I18n.locale == :ru
  end
end
