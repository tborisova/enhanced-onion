# app/graphql/sources/active_record_source.rb
class Sources::ActiveRecordSource < GraphQL::Dataloader::Source
  def initialize(model_class, foreign_key)
    @model_class = model_class
    @foreign_key = foreign_key
  end

  # This method is called when dataloader.load is invoked
  def fetch(ids)
    # Batch load the records using ActiveRecord and the foreign_key
    records = @model_class.where(@foreign_key => ids).to_a

    # Group records by foreign key (e.g., user_id)
    records_by_id = records.group_by { |record| record[@foreign_key] }

    # For each id requested, return the associated records or an empty array if none found
    ids.map { |id| records_by_id[id] || [] }
  end
end
