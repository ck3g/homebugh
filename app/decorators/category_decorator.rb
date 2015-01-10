class CategoryDecorator < Draper::Decorator
  delegate_all

  def type_icon
    object.income? ? h.up_arrow : h.down_arrow
  end

  def category_type
    if object.inactive?
      "bg-warning"
    elsif object.income?
      "bg-success"
    else
      "bg-danger"
    end
  end
end
