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
    with {:ok, chunked_path} <- mkdir_if_nonexistant(path <> ".chunked") do
      {:ok, %Chunker.WriteableChunkedFile{path: path, chunked_path: chunked_path, chunks: []}}
    else
      err -> err
    end
  end

  defp new_read_only_chunked_file(path) do
    {:ok, %Chunker.ReadOnlyChunkedFile{path: path, chunks: []}}
  end
end
