defmodule Chunker.DiscBased do
  @moduledoc """
  Provides functions to create readeable or writeable, disc-based,
  chunked files.
  """

  alias Chunker.DiscBased.ReadOnlyFile
  alias Chunker.DiscBased.WriteableFile

  @type t :: Chunker.t()

  @doc """
  Returns a writeable or readeable chunked file.

  If the first argument `path` does not point to an existing file,
  a new writeable chunked file is created.
  Otherwise opens the corresponding file for chunked reading.
  The second argument `chunk_size` sets the size of the individual 
  chunks.
  """
  @spec new(bitstring, integer) :: t
  def new(path, chunk_size \\ 1024 * 1024)
      when is_bitstring(path) and is_integer(chunk_size) and chunk_size > 0 do
    case File.stat(path) do
      {:ok, _} -> ReadOnlyFile.new(path, chunk_size)
      {:error, :enoent} -> WriteableFile.new(path, chunk_size)
      err -> err
    end
  end
end
