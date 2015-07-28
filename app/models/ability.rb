class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:

      user ||= User.new # guest user (not logged in)

      if user.super_admin?
        can :manage, :all
      elsif user.admin?

      else
        can :read, :all
      end
    #

  end
end
