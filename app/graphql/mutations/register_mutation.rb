module Mutations
  class RegisterMutation < Mutations::BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true
    argument :password_confirmation, String, required: true
    argument :name, String, required: true

    field :token, String, null: true
    field :error, String, null: true

    def resolve(email:, password:, password_confirmation:, name:)
      if password != password_confirmation
        return {token: nil, error: "Passwords don't match"}
      end

      user = User.new password:, password_confirmation:, name:, email: email

      if user.valid?
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
        { token: token[0], errors: [] }
      else
        { token: nil, error: user.errors.full_messages.join(', ') }
      end
    end
  end
end
