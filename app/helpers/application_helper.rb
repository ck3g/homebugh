# coding: utf-8

module ApplicationHelper
  def get_number_to_currency number
    number_to_currency number, :unit => 'лей', :format => '%n %u'
  end

  def get_account_funds(account_id, user_id = nil)
    user_id ||= current_user.id
    Account.where(:user_id => user_id).find(account_id).funds
  end

  def get_total_funds
    total_funds = 0
    Account.where(:user_id => current_user.id).each do |account|
      total_funds += get_account_funds(account.id).to_f
    end

    total_funds
  end

  def accounts_recalculate
    user_id = current_user.id

    account = Account.where(:user_id => user_id).first
    # todo: refactor to sum() method
    incomes = Transaction.includes(:category).where(:user_id => user_id, 'categories.category_type_id' => CategoryType.income).all
    total_income = 0.0
    incomes.each do |income|
      total_income += income.summ.to_f
    end

    # todo: refactor to sum() method
    spendings = Transaction.includes(:category).where(:user_id => user_id, 'categories.category_type_id' => CategoryType.spending).all
    total_spending = 0.0
    spendings.each do |spending|
      total_spending += spending.summ.to_f
    end

    diff = total_income - total_spending

    account.deposit(diff)
    Transaction.where(:user_id => user_id).update_all(:account_id => account.id)
  end

  def get_total_income( account_id, user_id = nil )
    get_total_by_type(1, account_id, user_id)
  end

  def get_total_spending( account_id, user_id = nil )
    get_total_by_type(2, account_id, user_id)
  end

  def language_selector
    to_locale = is_ru? ? 'en' : 'ru'
    content_tag :li, link_to("?locale=#{to_locale}") { image_tag("flags/#{to_locale}.png") }
  end

  def menu_items
    %w(transactions categories accounts cash_flows statistics)
  end

  def menu_item(for_controller, add_class = true)
    menu_link = link_to send("#{for_controller}_path") do
      content_tag :span, t("main_menu.#{for_controller}")
    end
    class_name = add_class && @controller_name == for_controller ? "selected" : ""
    content_tag :li, menu_link, :class => class_name
  end

  private

  def is_ru?
    I18n.locale == :ru
  end

  def is_en?
    I18n.locale == :en
  end

  def get_total_by_type(type_id, account_id, user_id = nil)
    user_id ||= current_user.id
    transactions = Transaction.includes(:category ).where('categories.category_type_id' => type_id, :user_id => user_id, :account_id => account_id)
    total_funds = 0
    transactions.each do |transaction|
      total_funds += transaction.summ.to_f
    end

    total_funds
  end
end
