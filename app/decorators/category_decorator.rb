class CategoryDecorator < Draper::Decorator
  delegate_all

  def type_icon
    object.income? ? h.up_arrow : h.down_arrow
  end
end
