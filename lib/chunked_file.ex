defprotocol Chunker.ChunkedFile do
  def add_chunk(chunked_file, data)
  def remove_chunk(chunked_file, index)
  def write_chunk(chunked_file, chunk)
  def commit(chunked_file)
  def writeable?(chunked_file)
  def chunk_path(chunked_file, chunk_or_index)
end