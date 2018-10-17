defprotocol Chunker.ChunkedFile do
  @moduledoc """
  Protocol for custom implementation of chunked files.
  """

  @type error_tuple :: Chunker.error_tuple()
  @type result :: Chunker.result()

  @doc """
  Inserts `data` to the given `chunked_file` at the position specified
  by `index`.
  """
  @spec insert_chunk(t, bitstring, integer) :: result
  def insert_chunk(chunked_file, data, index)

  @doc """
  Removes the chunk with the corresponding `index` from the given
  `chunked_file`.
  """
  @spec remove_chunk(t, integer) :: result
  def remove_chunk(chunked_file, index)

  @doc """
  Returns the data of the chunk with `index` from the given 
  `chunked_file`.
  """
  @spec get_chunk(t, integer) :: {:ok, bitstring} | error_tuple
  def get_chunk(chunked_file, index)

  @doc """
  Returns the number of individual chunks the given `chunked_file`
  consists of.
  """
  @spec length(t) :: {:ok, integer} | error_tuple
  def length(chunked_file)

  @doc """
  Commits the given `chunked_file`.

  After the file has been committed, chunks can no longer be added or
  removed.
  """
  @spec commit(t) :: result
  def commit(chunked_file)

  @doc """
  Returns `true` if chunks can be added or removed from the given
  `chunked_file`.
  """
  @spec writeable?(t) :: boolean
  def writeable?(chunked_file)

  @doc """
  Removes the given `chunked_file`.
  """
  @spec remove(t) :: :ok | error_tuple
  def remove(chunked_file)

  @doc """
  Closes the given `chunked_file`.

  After the file has been closed, it is not possible to read from it
  nor write to it.
  """
  @spec close(t) :: :ok | error_tuple
  def close(chunked_file)

  @doc """
  Returns `true` if the given `chunked_file` has already been closed.
  """
  @spec closed?(t) :: boolean
  def closed?(chunked_file)
end
