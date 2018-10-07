defmodule Chunker do
  @moduledoc """
  Provides functions to interact with chunked files.
  """

  alias Chunker.ChunkedFile

  @type t :: ChunkedFile.t()
  @type reason :: any
  @type success_tuple :: {:ok, t}
  @type error_tuple :: {:error, reason}
  @type result :: success_tuple | error_tuple

  @doc """
  Appends `data` to the given `chunked_file`.
  """
  @spec append_chunk(t, bitstring) :: result
  defdelegate append_chunk(chunked_file, data), to: ChunkedFile

  @doc """
  Inserts `data` to the given `chunked_file` at the position specified
  by `index`.
  """
  @spec insert_chunk(t, bitstring, integer) :: result
  defdelegate insert_chunk(chunked_file, data, index), to: ChunkedFile

  @doc """
  Removes the chunk with the corresponding `index` from the given
  `chunked_file`.
  """
  @spec remove_chunk(t, integer) :: result
  defdelegate remove_chunk(chunked_file, index), to: ChunkedFile

  @doc """
  Returns the data of the chunk with `index` from the given 
  `chunked_file`.
  """
  @spec chunk(t, integer) :: {:ok, bitstring} | error_tuple
  defdelegate chunk(chunked_file, index), to: ChunkedFile

  @doc """
  Returns the number of individual chunks the given `chunked_file`
  consists of.
  """
  @spec length(t) :: {:ok, integer} | error_tuple
  defdelegate length(chunked_file), to: ChunkedFile

  @doc """
  Commits the given `chunked_file`.

  After the file has been committed, chunks can no longer be added or
  removed.
  """
  @spec commit(t) :: result
  defdelegate commit(chunked_file), to: ChunkedFile

  @doc """
  Returns `true` if chunks can be added or removed from the given
  `chunked_file`.
  """
  @spec writeable?(t) :: boolean
  defdelegate writeable?(chunked_file), to: ChunkedFile

  @doc """
  Removes the given `chunked_file`.
  """
  @spec remove(t) :: :ok | error_tuple
  defdelegate remove(chunked_file), to: ChunkedFile

  @doc """
  Closes the given `chunked_file`.

  After the file has been closed, it is not possible to read from it
  nor write to it.
  """
  @spec close(t) :: :ok | error_tuple
  defdelegate close(chunked_file), to: ChunkedFile

  @doc """
  Returns `true` if the given `chunked_file` has already been closed.
  """
  @spec closed?(t) :: boolean
  defdelegate closed?(chunked_file), to: ChunkedFile
end
