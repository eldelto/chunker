defprotocol Chunker.ChunkedFile do
  @type path :: String.t()
  @type chunk :: any
  @type reason :: any
  @type error :: {:error, reason}
  @type result :: {:ok, t} | error

  @spec append_chunk(t, any) :: result
  def append_chunk(chunked_file, data)

  @spec insert_chunk(t, any, integer) :: result
  def insert_chunk(chunked_file, data, index)

  @spec remove_chunk(t, integer) :: result
  def remove_chunk(chunked_file, index)

  # def replace_chunk(chunked_file, data, index)

  @spec commit(t) :: path | error
  def commit(chunked_file)

  @spec writeable?(t) :: boolean
  def writeable?(chunked_file)

  @spec chunk(t, integer) :: {:ok, chunk} | error
  def chunk(chunked_file, index)

  @spec chunks(t) :: {:ok, [integer]} | error
  def chunks(chunked_file)

  @spec path(t) :: path | error
  def path(chunked_file)

  @spec remove(t) :: :ok | error
  def remove(chunked_file)

  @spec close(t) :: :ok | error
  def close(chunked_file)

  @spec closed?(t) :: boolean
  def closed?(chunked_file)
end
