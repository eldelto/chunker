defmodule Chunker.DiscBased.WriteableFile do
  @moduledoc false

  use GenServer

  alias Chunker.AlreadyCommittedError
  alias Chunker.DiscBased.Helper

  defstruct path: nil, chunked_path: nil, pid: nil

  ## Client ##
  def new(path) do
    with {:ok, chunked_path} <- mkdir_if_nonexistant(path <> ".chunked"),
         :ok <- create_chunk_map(chunked_path),
         {:ok, pid} <- GenServer.start_link(__MODULE__, :ok, []) do
      {:ok, %__MODULE__{path: path, chunked_path: chunked_path, pid: pid}}
    else
      err -> err
    end
  end

  def append_chunk(chunked_file, data) do
    with true <- Process.alive?(chunked_file.pid),
         :ok <- GenServer.call(chunked_file.pid, {:append_chunk, chunked_file, data}) do
      {:ok, chunked_file}
    else
      false -> {:error, %AlreadyCommittedError{}}
      err -> err
    end
  end

  def insert_chunk(chunked_file, data, index) when is_integer(index) and index >= 0 do
    with true <- Process.alive?(chunked_file.pid),
         :ok <- GenServer.call(chunked_file.pid, {:insert_chunk, chunked_file, data, index}) do
      {:ok, chunked_file}
    else
      false -> {:error, %AlreadyCommittedError{}}
      err -> err
    end
  end

  def remove_chunk(chunked_file, index) when is_integer(index) and index >= 0 do
    with true <- Process.alive?(chunked_file.pid),
         :ok <- GenServer.call(chunked_file.pid, {:remove_chunk, chunked_file, index}) do
      {:ok, chunked_file}
    else
      false -> {:error, %AlreadyCommittedError{}}
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

  def length(chunked_file) do
    case Helper.read_chunk_map(chunked_file) do
      {:ok, chunks} -> {:ok, Kernel.length(chunks)}
      err -> err
    end
  end

  def commit(chunked_file) do
    case Process.alive?(chunked_file.pid) do
      true -> GenServer.call(chunked_file.pid, {:commit, chunked_file})
      false -> {:error, %AlreadyCommittedError{}}
    end
  end

  def path(chunked_file), do: chunked_file.path

  def remove(chunked_file) do
    case File.rm_rf(chunked_file.chunked_path) do
      {:ok, _} -> :ok
      err -> err
    end
  end

  def close(chunked_file) do
    case Process.alive?(chunked_file.pid) do
      true -> GenServer.stop(chunked_file.pid)
      false -> {:error, %AlreadyCommittedError{}}
    end
  end

  def closed?(chunked_file) do
    !Process.alive?(chunked_file.pid)
  end

  ## Server ##
  @impl true
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:append_chunk, chunked_file = %__MODULE__{}, data}, _from, state) do
    result =
      Helper.add_chunk(chunked_file, data, 0, fn chunks, chunk_index, _ ->
        chunks ++ [chunk_index]
      end)

    {:reply, result, state}
  end

  @impl true
  def handle_call({:insert_chunk, chunked_file = %__MODULE__{}, data, index}, _from, state) do
    result =
      Helper.add_chunk(chunked_file, data, index, fn chunks, chunk_index, index ->
        List.insert_at(chunks, index, chunk_index)
      end)

    {:reply, result, state}
  end

  @impl true
  def handle_call({:remove_chunk, chunked_file = %__MODULE__{}, index}, _from, state) do
    result =
      with {:ok, chunks} <- Helper.read_chunk_map(chunked_file),
           {:ok, chunk_path} <- Helper.mapped_chunk_path(chunked_file, chunks, index),
           :ok <- File.rm(chunk_path),
           new_chunks <- List.delete_at(chunks, index) do
        Helper.write_chunk_map(chunked_file, new_chunks)
      else
        err -> err
      end

    {:reply, result, state}
  end

  @impl true
  def handle_call({:commit, chunked_file = %__MODULE__{}}, _from, state) do
    result =
      with {:ok, target} <- Helper.file_stream(chunked_file.path),
           {:ok, chunks} <- Helper.read_chunk_map(chunked_file),
           :ok <-
             chunks
             |> Stream.map(&Helper.chunk_path(chunked_file, &1))
             |> Stream.flat_map(&File.stream!(&1, [:read], 4096))
             |> Stream.into(target)
             |> Stream.run(),
           :ok <- remove(chunked_file) do
        {:ok, chunked_file.path}
      else
        err -> err
      end

    {:stop, :normal, result, state}
  end

  @impl true
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
    File.touch(chunk_map_path)
  end
end

defimpl Chunker.ChunkedFile, for: Chunker.DiscBased.WriteableFile do
  alias Chunker.DiscBased.WriteableFile
  alias Chunker.DiscBased.Helper

  defdelegate append_chunk(chunked_file, data), to: WriteableFile

  defdelegate insert_chunk(chunked_file, data, index), to: WriteableFile

  defdelegate remove_chunk(chunked_file, index), to: WriteableFile

  def chunk(chunked_file, index) when is_integer(index) and index >= 0 do
    with {:ok, chunks} <- Helper.read_chunk_map(chunked_file),
         {:ok, chunk_path} <- Helper.mapped_chunk_path(chunked_file, chunks, index) do
      File.read(chunk_path)
    else
      err -> err
    end
  end

  defdelegate length(chunked_file), to: WriteableFile

  defdelegate commit(chunked_file), to: WriteableFile

  def writeable?(_), do: true

  def path(chunked_file), do: chunked_file.path

  defdelegate remove(chunked_file), to: WriteableFile

  defdelegate close(chunked_file), to: WriteableFile

  defdelegate closed?(chunked_file), to: WriteableFile
end
