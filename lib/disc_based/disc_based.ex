defmodule Chunker.DiscBased do
  @moduledoc """
  Provides functions to create readeable or writeable, disc-based,
  chunked files.
  """

  alias Chunker.DiscBased.ReadOnlyFile
  alias Chunker.DiscBased.WriteableFile

  @doc """
  Returns a writeable or readeable chunked file.

  If the first argument `path` does not point to an existing file,
  a new writeable chunked file is created.
  Otherwise opens the corresponding file for chunked reading.
  The second argument `chunk_size` sets the size of the individual 
  chunks.
  """
  def new(path, chunk_size \\ 1024 * 1024)
      when is_bitstring(path) and is_integer(chunk_size) and chunk_size > 0 do
    case File.stat(path) do
      {:ok, _} -> new_read_only_chunked_file(path, chunk_size)
      {:error, :enoent} -> new_writeable_chunked_file(path)
      err -> err
    end
  end

  defp new_writeable_chunked_file(path) do
    WriteableFile.new(path)
  end

  defp new_read_only_chunked_file(path, chunk_size) do
    ReadOnlyFile.new(path, chunk_size)
  end
end