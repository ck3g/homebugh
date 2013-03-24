module TransactionsHelper
  def category_name(transaction)
    if transaction.category
      transaction.category_name
    else
      t('parts.transactions.no_category')
    end
  end
end
