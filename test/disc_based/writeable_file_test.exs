defmodule Chunker.DiscBased.WriteableFileTest do
  use ExUnit.Case

  alias Chunker.AlreadyCommittedError
  alias Chunker.DiscBased
  alias Chunker.DiscBased.WriteableFile
  alias Chunker.InvalidIndexError

  doctest WriteableFile

  @writeable_file_path "test/resources/tmp/chunked_file.txt"
  @chunk_path "test/resources/tmp/chunked_file.txt.chunked/0.chunk"
  @chunk_path_1 "test/resources/tmp/chunked_file.txt.chunked/1.chunk"
  @chunk_path_2 "test/resources/tmp/chunked_file.txt.chunked/2.chunk"

  @tmp_path "test/resources/tmp/*"

  setup do
    on_exit(fn ->
      :os.cmd(to_charlist("rm -rf " <> @tmp_path))
    end)
  end

  test "new ChunkedFile" do
    assert %WriteableFile{} = new_chunked_file()
  end

  test "appending chunks" do
    chunked_file = new_chunked_file()

    assert {:ok, _} = Chunker.append_chunk(chunked_file, "test")
    assert {:ok, _} = Chunker.append_chunk(chunked_file, "test")

    assert {:ok, _} = File.stat(@chunk_path)
    assert {:ok, _} = File.stat(@chunk_path_1)
    assert {:ok, "0,1"} = File.read(chunk_map_path(chunked_file))
  end

  test "committing ChunkedFile" do
    chunked_file = new_chunked_file()

    {:ok, _} = Chunker.append_chunk(chunked_file, "hello ")
    {:ok, _} = Chunker.append_chunk(chunked_file, "world")
    assert {:ok, path} = Chunker.commit(chunked_file)
    assert @writeable_file_path = path
    assert {:ok, "hello world"} = File.read(@writeable_file_path)
    assert {:error, :enoent} = File.lstat(@writeable_file_path <> ".chunked")
  end

  test "inserting chunk" do
    chunked_file = new_chunked_file()

    assert {:ok, _} = Chunker.append_chunk(chunked_file, "hello")
    assert {:ok, _} = Chunker.append_chunk(chunked_file, "world")
    assert {:ok, _} = Chunker.insert_chunk(chunked_file, " test ", 1)

    assert {:ok, _} = File.stat(@chunk_path)
    assert {:ok, _} = File.stat(@chunk_path_1)
    assert {:ok, _} = File.stat(@chunk_path_2)
    assert {:ok, "0,2,1"} = File.read(chunk_map_path(chunked_file))

    assert {:ok, path} = Chunker.commit(chunked_file)
    assert @writeable_file_path = path
    assert {:ok, "hello test world"} = File.read(@writeable_file_path)
  end

  test "getting chunk" do
    chunked_file = new_chunked_file()

    {:ok, _} = Chunker.append_chunk(chunked_file, "hello")
    {:ok, _} = Chunker.append_chunk(chunked_file, "world")

    assert {:ok, "world"} = Chunker.chunk(chunked_file, 1)
    assert {:error, %InvalidIndexError{}} = Chunker.chunk(chunked_file, 100)
  end

  test "getting chunk list" do
    chunked_file = new_chunked_file()

    {:ok, _} = Chunker.append_chunk(chunked_file, "hello")
    {:ok, _} = Chunker.append_chunk(chunked_file, "world")

    assert {:ok, chunks} = Chunker.chunks(chunked_file)
    assert 2 == length(chunks)
  end

  test "removing chunk" do
    chunked_file = new_chunked_file()
    {:ok, _} = Chunker.append_chunk(chunked_file, "hello ")
    {:ok, _} = Chunker.append_chunk(chunked_file, "world")

    assert {:ok, _} = Chunker.remove_chunk(chunked_file, 0)
    assert {:ok, "1"} = File.read(chunk_map_path(chunked_file))
    {:ok, _} = Chunker.commit(chunked_file)
    assert {:ok, "world"} = File.read(@writeable_file_path)
  end

  test "writeable?" do
    chunked_file = new_chunked_file()
    assert true === Chunker.writeable?(chunked_file)
  end

  test "path" do
    chunked_file = new_chunked_file()
    assert @writeable_file_path = Chunker.path(chunked_file)
  end

  test "removing ChunkedFile" do
    chunked_file = new_chunked_file()

    assert :ok = Chunker.remove(chunked_file)
    assert {:error, :enoent} = File.stat(chunked_file.chunked_path)
  end

  test "closing ChunkedFile" do
    chunked_file = new_chunked_file()

    assert :ok = Chunker.close(chunked_file)
    assert {:error, %AlreadyCommittedError{}} = Chunker.append_chunk(chunked_file, "hello")
  end

  test "closed?" do
    chunked_file = new_chunked_file()

    assert false === Chunker.closed?(chunked_file)

    :ok = Chunker.close(chunked_file)
    assert true === Chunker.closed?(chunked_file)
  end

  defp new_chunked_file do
    {:ok, chunked_file} = DiscBased.new(@writeable_file_path)
    chunked_file
  end

  defp chunk_map_path(chunked_file) do
    Path.join(chunked_file.chunked_path, "chunk_map")
  end
end
