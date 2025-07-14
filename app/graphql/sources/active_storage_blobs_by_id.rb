class Sources::ActiveStorageBlobsById < GraphQL::Dataloader::Source
  def fetch(blob_ids)
    blobs = ActiveStorage::Blob.where(id: blob_ids).index_by(&:id)
    blob_ids.map { |id| blobs[id] }
  end
end
