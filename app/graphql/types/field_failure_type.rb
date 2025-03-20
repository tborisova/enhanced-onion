module Types
  class FieldFailureType < GraphQL::Schema::Object
    FieldFailure = Struct.new :field, :message

    field :field, String, null: false
    field :message, String, null: false
  end
end
