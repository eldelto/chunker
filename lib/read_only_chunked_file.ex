defmodule Chunker.ReadOnlyChunkedFile do
  defstruct path: nil, chunks: []
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
