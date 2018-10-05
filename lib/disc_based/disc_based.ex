defmodule Chunker.DiscBased do
  alias Chunker.DiscBased.ReadOnlyFile
  alias Chunker.DiscBased.WriteableFile

  def new(path, chunk_size \\ 1024 * 1024) do
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
