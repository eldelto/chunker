defmodule Chunker.WriteableChunkedFile do
  defstruct path: nil, chunked_path: nil, chunks: []
end

defimpl Chunker.ChunkedFile, for: Chunker.WriteableChunkedFile do
  alias Chunker.Chunk

  def add_chunk(chunked_file, data) do
    index = length(chunked_file.chunks)

    with {:ok, chunk} <- Chunk.new(index, data) do
      write_chunk(chunked_file, chunk)
    else
      err -> err
    end
  end

  def write_chunk(chunked_file, chunk = %Chunk{data: data}) do
    with {:ok, path} <- chunk_path(chunked_file, chunk),
          :ok <- File.write(path, data),
          new_chunk <- %{chunk | data: nil},
          new_chunks <- [new_chunk] ++ chunked_file.chunks,
          new_chunked_file <- %{chunked_file | chunks: new_chunks} do
      {:ok, new_chunked_file}
    else
      err -> err
    end
  end

  def remove_chunk(chunked_file, index) when is_integer(index) do
    {:ok, chunk_path} = chunk_path(chunked_file, index)
    case File.rm(chunk_path) do
      :ok -> {:ok, nil}
      err -> err
    end
  end

  def commit(chunked_file) do
    #TODO: add rescue block just in case
    with {:ok, target} <- get_file_stream(chunked_file.path),
          {:ok, files} <-File.ls(chunked_file.chunked_path),
          :ok <- Stream.map(files, &(Path.join(chunked_file.chunked_path, &1)))
                |>Stream.flat_map(&(File.stream!(&1, [:read], 4096)))
                |> Stream.into(target)
                |> Stream.run() do
      {:ok, chunked_file.path}            
    else
      err -> err
    end
  end

  def writeable?(_), do: true

  def chunk_path(chunked_file, index) when is_integer(index) do
    path = Path.join([chunked_file.chunked_path, to_string(index) <> ".chunk"])
    {:ok, path}
  end

  def chunk_path(chunked_file, chunk) do
    chunk_path(chunked_file, chunk.index)
  end

  def remove(chunked_file) do
    case File.rm_rf(chunked_file.chunked_path) do
      :ok -> {:ok, nil}
      err -> err
    end
  end

  defp get_file_stream(path) do
    try do
      file = File.stream!(path, [:append], 4096)
      {:ok, file}
    rescue
      e in RuntimeError -> {:error, e.message}
    end
  end
end