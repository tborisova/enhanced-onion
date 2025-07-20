class PlanLimit
  def initialize(user)
    @user = user
    @plan = user.plan
  end

  def recipes_quota_reached?
    @recipes_reached ||=
      @plan.is_free ? false : @plan.recipes_quota < @user.recipes.count
  end

  def images_quota_reached?
    @images_reached ||=
      @plan.is_free ? false : @plan.images_quota < @user.recipes.joins(:photo_attachment).count
  end
end
