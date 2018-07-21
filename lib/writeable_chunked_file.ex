defmodule Chunker.WriteableChunkedFile do
  use GenServer
  
  alias Chunker.Helper

  defstruct path: nil, chunked_path: nil, pid: nil

  ## Client ##
  def new(path) do
    with {:ok, chunked_path} <- mkdir_if_nonexistant(path <> ".chunked"),
          {:ok, _} <- create_chunk_map(chunked_path),
          {:ok, pid} <- GenServer.start_link(__MODULE__, :ok, []) do
      {:ok, %__MODULE__{path: path, chunked_path: chunked_path, pid: pid}}
    else
      err -> err
    end
  end

  def append(chunked_file, data) do
    case Process.alive?(chunked_file.pid) do
      true -> GenServer.call(chunked_file.pid, {:append, chunked_file, data})
      false -> already_closed()
    end
  end

  def insert(chunked_file, data, index) when is_integer(index) and index >= 0 do
    case Process.alive?(chunked_file.pid) do
      true -> GenServer.call(chunked_file.pid, {:insert, chunked_file, data, index})
      false -> already_closed()
    end
  end

  def remove(chunked_file, index) when is_integer(index) and index >= 0 do
    case Process.alive?(chunked_file.pid) do
      true -> GenServer.call(chunked_file.pid, {:remove, chunked_file, index})
      false -> already_closed()
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
    case Process.alive?(chunked_file.pid) do
      true -> GenServer.call(chunked_file.pid, {:commit, chunked_file})
      false -> already_closed()
    end
  end

  def path(chunked_file), do: chunked_file.path
  
  def delete(chunked_file) do    
    case File.rm_rf(chunked_file.chunked_path) do
      :ok -> {:ok, nil}
      err -> err
    end
  end

  def close(chunked_file) do
    case Process.alive?(chunked_file.pid) do
      true -> GenServer.stop(chunked_file.pid)
      false -> already_closed()
    end
  end

  def closed?(chunked_file) do
    !Process.alive?(chunked_file.pid)
  end

  ## Server ##
  def init(:ok) do
    {:ok, nil}
  end

  def handle_call({:append, chunked_file = %__MODULE__{}, data}, _from, state) do
    #TODO: Use stream instead of data
    result = Helper.add_chunk(chunked_file, data, 0, fn(chunks, chunk_index, _) ->
      chunks ++ [chunk_index]
    end)

    {:reply, result, state}
  end

  def handle_call({:insert, chunked_file = %__MODULE__{}, data, index}, _from, state) do
    #TODO: Use stream instead of data
    result = Helper.add_chunk(chunked_file, data, index, fn(chunks, chunk_index, index) ->
      List.insert_at(chunks, index, chunk_index)
    end)

    {:reply, result, state}
  end

  def handle_call({:remove, chunked_file = %__MODULE__{}, index}, _from, state) do
    result = with {:ok, chunks} <- Helper.read_chunk_map(chunked_file),
          {:ok, chunk_path} <- Helper.mapped_chunk_path(chunked_file, chunks, index),
          :ok <- File.rm(chunk_path),
          new_chunks <- List.delete_at(chunks, index),
          {:ok, _} <- Helper.write_chunk_map(chunked_file, new_chunks) do
      {:ok, nil}
    else
      err -> err
    end

    {:reply, result, state}
  end

  def handle_call({:commit, chunked_file = %__MODULE__{}}, _from, state) do
    #TODO: Add rescue block just in case
    result = with {:ok, target} <- Helper.file_stream(chunked_file.path),
          {:ok, chunks} <- Helper.read_chunk_map(chunked_file),
          :ok <- Stream.map(chunks, &(Helper.chunk_path(chunked_file, &1)))
                 |> Stream.flat_map(&(File.stream!(&1, [:read], 4096)))
                 |> Stream.into(target)
                 |> Stream.run(),
          {:ok, _} <- delete(chunked_file) do          
      {:ok, chunked_file.path}
    else
      err -> err
    end

    {:stop, :normal, result, state}
  end

  def terminate(reason, _state) do
    {:shutdown, reason}
  end

  ## Helper functions ##
  defp mkdir_if_nonexistant(path) do
    case File.mkdir(path) do
      :ok -> {:ok, path}
      {:error, :eexist} -> {:ok, path}
      err -> err
    end
  end

  defp create_chunk_map(path) do
    chunk_map_path = Path.join(path, "chunk_map")
    case File.touch(chunk_map_path) do
      :ok -> {:ok, nil}
      err -> err
    end
  end

  defp already_closed(), do: {:error, "Already closed."}
end

defimpl Chunker.ChunkedFile, for: Chunker.WriteableChunkedFile do
  alias Chunker.WriteableChunkedFile
  alias Chunker.Helper

  def append_chunk(chunked_file, data) do
    WriteableChunkedFile.append(chunked_file, data)
  end

  def insert_chunk(chunked_file, data, index) when is_integer(index) and index >= 0 do
    WriteableChunkedFile.insert(chunked_file, data, index)
  end

  def remove_chunk(chunked_file, index) when is_integer(index) and index >= 0 do
    WriteableChunkedFile.remove(chunked_file, index)
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
    WriteableChunkedFile.commit(chunked_file)
  end

  def writeable?(_), do: true

  def path(chunked_file), do: chunked_file.path
  
  def remove(chunked_file) do
    WriteableChunkedFile.delete(chunked_file)
  end
  
  def close(chunked_file) do
    WriteableChunkedFile.close(chunked_file)
  end

  def closed?(chunked_file) do
    WriteableChunkedFile.closed?(chunked_file)
  end
end