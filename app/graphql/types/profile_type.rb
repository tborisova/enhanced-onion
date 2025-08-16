module Types
  class ProfileType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false
    field :has_free_plan, Boolean, null: false
    field :recipes_quota_reached, Boolean, null: false
    field :images_quota_reached, Boolean, null: false
    field :remaining_recipes_count, Boolean, null: true
    field :remaining_images_count, Boolean, null: true
    field :suspended, Boolean, null: false

    def id = object.to_gid_param
    def has_free_plan = plan_limits[:free]
    def recipes_quota_reached = plan_limits[:recipes_quota_reached]
    def images_quota_reached = plan_limits[:images_quota_reached]
    def remaining_recipes_count = plan_limits[:remaining_recipes_count]
    def remaining_images_count = plan_limits[:remaining_images_count]

    private

    def plan_limits
      @plan_limits ||= object.plan_limits
    end
  end
end
