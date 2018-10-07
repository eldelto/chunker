defmodule Chunker do
  @moduledoc """
  Provides functions to interact with chunked files.
  """

  alias Chunker.ChunkedFile

  @doc """
  Appends `data` to the given `chunked_file`.
  """
  defdelegate append_chunk(chunked_file, data), to: ChunkedFile

  @doc """
  Inserts `data` to the given `chunked_file` at the position specified
  by `index`.
  """
  defdelegate insert_chunk(chunked_file, data, index), to: ChunkedFile

  @doc """
  Removes the chunk with the corresponding `index` from the given
  `chunked_file`.
  """
  defdelegate remove_chunk(chunked_file, index), to: ChunkedFile

  @doc """
  Returns the data of the chunk with `index` from the given 
  `chunked_file`.
  """
  defdelegate chunk(chunked_file, index), to: ChunkedFile

  @doc """
  Returns the number of individual chunks the given `chunked_file`
  consists of.
  """
  defdelegate length(chunked_file), to: ChunkedFile

  @doc """
  Commits the given `chunked_file`.

  After the file has been committed, chunks can no longer be added or
  removed.
  """
  defdelegate commit(chunked_file), to: ChunkedFile

  @doc """
  Returns `true` if chunks can be added or removed from the given
  `chunked_file`.
  """
  defdelegate writeable?(chunked_file), to: ChunkedFile

  @doc """
  Removes the given `chunked_file`.
  """
  defdelegate remove(chunked_file), to: ChunkedFile

  @doc """
  Closes the given `chunked_file`.

  After the file has been closed, it is not possible to read from it
  nor write to it.
  """
  defdelegate close(chunked_file), to: ChunkedFile

  @doc """
  Returns `true` if the given `chunked_file` has already been closed.
  """
  defdelegate closed?(chunked_file), to: ChunkedFile
end
