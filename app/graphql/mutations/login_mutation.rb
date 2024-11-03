module Mutations
  class LoginMutation < Mutations::BaseMutation
    argument :email, String, required: true
    argument :password, String, required: true

    field :token, String, null: true
    field :errors, [String], null: false

    def resolve(email:, password:)
      user = User.find_for_authentication(email: email)
      if user&.valid_password?(password)
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
        { token: token[0], errors: [] }
      else
        { token: nil, errors: ["Invalid credentials"] }
      end
    end
  end
end
