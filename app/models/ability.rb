class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    entities = [Transaction, Category, Account, CashFlow, Budget, RecurringPayment]

    cannot :all, :all

    if user.persisted?
      can [:index, :archived], :statistics

      can :create, entities
      can [:read, :manage], entities, user_id: user.id
    end
  end
end
