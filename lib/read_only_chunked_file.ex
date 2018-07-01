defmodule Chunker.ReadOnlyChunkedFile do
  defstruct path: nil, chunk_size: 4
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

  def chunk(chunked_file, index) when is_integer(index) and index >= 0 do
    chunk_size = chunked_file.chunk_size
    with {:ok, io_device} <- :file.open(chunked_file.path, [:read, :binary]) do
      :file.pread(io_device, {:bof, index * chunk_size}, chunk_size)
    else
      err -> err
    end
  end

  def chunks(chunked_file) do
    case File.stat(chunked_file.path) do
      {:ok, %{size: size}} -> number_of_chunks = size / chunked_file.chunk_size
                              number_of_chunks = trunc(Float.ceil(number_of_chunks))
                              {:ok, Enum.to_list(1..number_of_chunks)}
      
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
