defmodule Chunker.ReadOnlyChunkedFile do
  defstruct path: nil, chunks: [], chunk_size: 4
end

defimpl Chunker.ChunkedFile, for: Chunker.ReadOnlyChunkedFile do
  alias Chunker.Helper

  def append_chunk(_, _) do
    not_writeable()
  end

  def insert_chunk(_, _, _) do
    not_writeable()
  end

  def remove_chunk(_, _) do
    not_writeable()
  end

  def get_chunk(chunked_file, index) when is_integer(index) and index >= 0 do
    chunk_size = chunked_file.chunk_size
    with {:ok, io_device} <- :file.open(chunked_file.path, [:read, :binary]) do
      :file.pread(io_device, {:bof, index * chunk_size}, chunk_size)
    else
      err -> err
    end
  end

  def commit(_) do
    not_writeable()
  end

  def writeable?(_), do: false
  
  def remove(_) do
    not_writeable()
  end

  ## Helper functions ##
  defp not_writeable(), do: {:error, "This ChunkedFile is read-only."}
end
