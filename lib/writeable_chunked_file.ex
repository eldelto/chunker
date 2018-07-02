defmodule Chunker.WriteableChunkedFile do
  defstruct path: nil, chunked_path: nil
end

defimpl Chunker.ChunkedFile, for: Chunker.WriteableChunkedFile do
  alias Chunker.Helper

  def append_chunk(chunked_file, data) do
    #TODO: Use stream instead of data
    Helper.add_chunk(chunked_file, data, 0, fn(chunks, chunk_index, _) ->
      chunks ++ [chunk_index]
    end)  
  end

  def insert_chunk(chunked_file, data, index) when is_integer(index) and index >= 0 do
    #TODO: Use stream instead of data
    Helper.add_chunk(chunked_file, data, index, fn(chunks, chunk_index, index) ->
      List.insert_at(chunks, index, chunk_index)
    end)
  end

  def remove_chunk(chunked_file, index) when is_integer(index) and index >= 0 do
    with {:ok, chunks} <- Helper.read_chunk_map(chunked_file),
          {:ok, chunk_path} <- Helper.mapped_chunk_path(chunked_file, chunks, index),
          :ok <- File.rm(chunk_path),
          new_chunks <- List.delete_at(chunks, index),
          {:ok, _} <- Helper.write_chunk_map(chunked_file, new_chunks) do
      {:ok, nil}
    else
      err -> err
    end
  end

  def chunk(chunked_file, index) when is_integer(index) and index >= 0 do
    with {:ok, chunks} <- Helper.read_chunk_map(chunked_file),
          {:ok, chunk_path} <- Helper.mapped_chunk_path(chunked_file, chunks, index) do
      File.read(chunk_path)
    else
      err -> err
    end
  end

  def chunks(chunked_file) do
    Helper.read_chunk_map(chunked_file)
  end

  def commit(chunked_file) do
    #TODO: Add rescue block just in case
    with {:ok, target} <- Helper.file_stream(chunked_file.path),
          {:ok, chunks} <- Helper.read_chunk_map(chunked_file),
          :ok <- Stream.map(chunks, &(Helper.chunk_path(chunked_file, &1)))
                 |> Stream.flat_map(&(File.stream!(&1, [:read], 4096)))
                 |> Stream.into(target)
                 |> Stream.run() do          
      {:ok, chunked_file.path}            
    else
      err -> err
    end
  end

  def writeable?(_), do: true

  def path(chunked_file), do: chunked_file.path
  
  def remove(chunked_file) do
    case File.rm_rf(chunked_file.chunked_path) do
      :ok -> {:ok, nil}
      err -> err
    end
  end
end