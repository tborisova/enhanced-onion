class Sources::ActiveStorageAttachmentsByRecord < GraphQL::Dataloader::Source
  def initialize(name:, record_type:)
    @name = name
    @record_type = record_type
  end

  def fetch(record_ids)
    attachments = ActiveStorage::Attachment
      .where(record_id: record_ids, record_type: @record_type, name: @name)
      .index_by(&:record_id)

    record_ids.map { |id| attachments[id] }
  end
end
