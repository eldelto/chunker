defmodule Chunker.DiscBased.ReadOnlyFile do
  @moduledoc false

  defstruct path: nil, chunk_size: 1024 * 1024

  def new(path, chunk_size) do
    {:ok, %__MODULE__{path: path, chunk_size: chunk_size}}
  end
end

defimpl Chunker.ChunkedFile, for: Chunker.DiscBased.ReadOnlyFile do
  alias Chunker.ReadOnlyError

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

    with {:ok, io_device} <- :file.open(chunked_file.path, [:read, :binary, :raw]),
         {:ok, data} <- :file.pread(io_device, index * chunk_size, chunk_size),
         :ok <- :file.close(io_device) do
      {:ok, data}
    else
      :eof -> {:error, :eof}
      err -> err
    end
  end

  def length(chunked_file) do
    case File.stat(chunked_file.path) do
      {:ok, %{size: size}} ->
        number_of_chunks =
          size
          |> Kernel./(chunked_file.chunk_size)
          |> Float.ceil()
          |> trunc()

        {:ok, number_of_chunks}

      err ->
        err
    end
  end

  def commit(_) do
    not_writeable()
  end

  def writeable?(_), do: false

  def path(chunked_file), do: chunked_file.path

  def remove(chunked_file) do
    case File.rm_rf(chunked_file.path) do
      {:ok, _} -> :ok
      err -> err
    end
  end

  def close(_) do
    not_writeable()
  end

  def closed?(_), do: false

  ## Helper functions ##
  defp not_writeable, do: {:error, %ReadOnlyError{}}
end
