defmodule Chunker.ReadOnlyChunkedFile do
  defstruct path: nil, chunks: [], chunk_size: 4
end

defimpl Chunker.ChunkedFile, for: Chunker.ReadOnlyChunkedFile do
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
