class Transaction < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  belongs_to :account

  validates :account_id, :category_id, :summ, presence: true
  validates :summ, numericality: true
  validate :cannot_be_less_than_0_01

  after_create :affect_on_account_after_create
  before_destroy :affect_on_account_before_destroy
  around_update :affect_on_account_around_update

  def income?
    self.category.category_type_id == CategoryType.income
  end

  private
  def affect_on_account_after_create
    Transaction.transaction do
      account.deposit(summ) if income?
      account.withdrawal(summ) unless income?
    end
  end

  def affect_on_account_before_destroy
    Transaction.transaction do
      account.withdrawal(summ) if income?
      account.deposit(summ) unless income?
    end
  end

  def affect_on_account_around_update
    Transaction.transaction do
      prev_account = account_id_changed? ? Account.find(account_id_was) : account
      prev_summ = summ_changed? ? summ_was : summ
      prev_category = category_id_changed? ? Category.find(category_id_was) : category

      prev_account.withdrawal(prev_summ) if prev_category.income?
      prev_account.deposit(prev_summ) unless prev_category.income?

      yield

      account.deposit(summ) if category.income?
      account.withdrawal(summ) unless category.income?
    end
  end

  def cannot_be_less_than_0_01
    errors.add(:summ, I18n.t('common.cannot_be_less_than', value: 0.01)) if summ.to_f < 0.01
  end

end
