module Mutations
  class UpdatePasswordMutation < BaseMutation
    argument :current_password, String, required: true
    argument :new_password, String, required: true

    field :errors, [Types::FieldFailureType], null: false
    field :success, Boolean, null: false

    def resolve(input)
      if context[:current_user].valid_password?(input[:current_password])
        context[:current_user].password = input[:new_password]
        context[:current_user].password_confirmation = input[:new_password]

        context[:current_user].validate

        if context[:current_user].errors.present?
          errors =
            context[:current_user].errors.map do |error|
              {field: error.attribute, message: error.message}
            end

            p errors
          {errors: errors, success: false}
        else
          context[:current_user].save!

          {errors: [], success: true}
        end
      else
        {errors: [{field: 'current_password', message: 'is invalid'}], success: false}
      end
    end
  end
end
