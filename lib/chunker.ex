defmodule Chunker do
  def new(path) do
    case File.stat(path) do
      {:ok, _} -> new_read_only_chunked_file(path)
      {:error, :enoent} -> new_writeable_chunked_file(path)
      err -> err
    end
    
  end
  
  defp mkdir_if_nonexistant(path) do
    case File.mkdir(path) do
      :ok -> {:ok, path}
      {:error, :eexist} -> {:ok, path}
      err -> err
    end
  end

  defp new_writeable_chunked_file(path) do
    with {:ok, chunked_path} <- mkdir_if_nonexistant(path <> ".chunked"),
    {:ok, _} <- create_chunk_map(chunked_path) do
      {:ok, %Chunker.WriteableChunkedFile{path: path, chunked_path: chunked_path}}
    else
      err -> err
    end
  end

  defp new_read_only_chunked_file(path) do
    {:ok, %Chunker.ReadOnlyChunkedFile{path: path}}
  end

  defp create_chunk_map(path) do
    chunk_map_path = Path.join(path, "chunk_map")
    case File.touch(chunk_map_path) do
      :ok -> {:ok, nil}
      err -> err
    end
  end
end
