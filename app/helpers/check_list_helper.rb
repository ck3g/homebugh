module CheckListHelper
  def check_li_done(&block)
    content_tag :li, class: "text-success" do
      yield
    end
  end

  def check_li_todo(&block)
    content_tag :li, class: "text-warning" do
      yield
    end
  end

  def check_icon_done
    fa_icon("circle")
  end

  def check_icon_todo
    fa_icon("circle-o")
  end
end
