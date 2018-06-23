defprotocol Chunker.ChunkedFile do
  def add_chunk(chunked_file, data)
  #def insert_chunk(chunked_file, chunk, index)
  def remove_chunk(chunked_file, index)  
  def commit(chunked_file)
  def writeable?(chunked_file)  
  #def get_chunk(chunked_file, index)
  def remove(chunked_file)
end