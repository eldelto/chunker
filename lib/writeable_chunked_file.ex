defmodule Chunker.WriteableChunkedFile do
  defstruct path: nil, chunked_path: nil, chunks: []
end

defimpl Chunker.ChunkedFile, for: Chunker.WriteableChunkedFile do
  def add_chunk(chunked_file, data) do
    #TODO: Use stream instead of data
    index = next_chunk_index(chunked_file)
    chunk_path = chunk_path(chunked_file, index)

    with :ok <- File.write(chunk_path, data),
          new_chunks <- chunked_file.chunks ++ [index],
          new_chunked_file = %{chunked_file | chunks: new_chunks},
          {:ok, _} <- write_chunk_map(new_chunked_file) do   
      {:ok, new_chunked_file}
    else
      err -> err
    end
  end

  def remove_chunk(chunked_file, index) when is_integer(index) do
    chunk_path = mapped_chunk_path(chunked_file, index)
    IO.puts("removing" <> chunk_path)
    with :ok <- File.rm(chunk_path),
         new_chunks <- List.delete_at(chunked_file.chunks, index),
         new_chunked_file = %{chunked_file | chunks: new_chunks},
         {:ok, _} <- write_chunk_map(new_chunked_file) do
      {:ok, new_chunked_file}
    else
      err -> err
    end
  end

  def commit(chunked_file) do
    #TODO: Add rescue block just in case
    with {:ok, target} <- file_stream(chunked_file.path),
          :ok <- Stream.map(chunked_file.chunks, &(chunk_path(chunked_file, &1)))
                 |> Stream.flat_map(&(File.stream!(&1, [:read], 4096)))
                 |> Stream.into(target)
                 |> Stream.run() do          
      {:ok, chunked_file.path}            
    else
      err -> err
    end
  end

  def writeable?(_), do: true
  
  def remove(chunked_file) do
    case File.rm_rf(chunked_file.chunked_path) do
      :ok -> {:ok, nil}
      err -> err
    end
  end

  ## Helper functions ##
  defp file_stream(path) do
    try do
      file = File.stream!(path, [:append], 4096)
      {:ok, file}
    rescue
      e in RuntimeError -> {:error, e.message}
    end
  end

  defp write_chunk_map(chunked_file) do
    content = Enum.join(chunked_file.chunks, ",")
    case File.write(chunk_map_path(chunked_file), content) do
      :ok -> {:ok, nil}
      err -> err
    end
  end

  defp read_chunk_map(chunked_file) do
    with {:ok, content} <- File.read(chunk_map_path(chunked_file)) do
      {:ok, String.split(content, ",")}
    else
      err -> err
    end    
  end

  defp chunk_map_path(chunked_file) do
    Path.join(chunked_file.chunked_path, "chunk_map")
  end

  defp next_chunk_index(chunked_file) do
    Enum.max(chunked_file.chunks, fn -> -1 end) + 1
  end

  defp chunk_path(chunked_file, index) do 
    #TODO: Return error when the index is not in chunks.
    Path.join(chunked_file.chunked_path, to_string(index) <> ".chunk")
  end

  defp mapped_chunk_path(chunked_file, index) do
    case Enum.fetch(chunked_file.chunks, index) do
      {:ok, chunk_index} -> chunk_path(chunked_file, chunk_index)
      :error -> {:error, "The index does not point to a valid chunk."}
    end    
  end
end