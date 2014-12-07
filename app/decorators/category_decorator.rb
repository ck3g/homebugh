class CategoryDecorator < Draper::Decorator
  delegate_all

  def type_icon
    if object.income?
      h.content_tag :span, h.fa_icon('arrow-up'), class: 'text-success'
    else
      h.content_tag :span, h.fa_icon('arrow-down'), class: 'text-danger'
    end
  end
end
