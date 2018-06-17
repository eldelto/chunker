defmodule WriteableChunkedFileTest do
  use ExUnit.Case

  alias Chunker.Chunk
  alias Chunker.ChunkedFile
  alias Chunker.WriteableChunkedFile

  doctest WriteableChunkedFile

  @writeable_file_path "test/resources/tmp/chunked_file.txt"
  @chunk_path "test/resources/tmp/chunked_file.txt.chunked/0.chunk"
  @chunk_path_1 "test/resources/tmp/chunked_file.txt.chunked/1.chunk"

  @tmp_path "test/resources/tmp/*"

  setup do
    on_exit(fn ->
      :os.cmd(to_charlist("rm -rf " <> @tmp_path))
    end)
  end

  test "new ChunkedFile" do
    assert %WriteableChunkedFile{} = new_chunked_file()
  end

  test "get Chunk path" do
    chunked_file = new_chunked_file()
    chunk = new_chunk()
    assert {:ok, @chunk_path} == ChunkedFile.chunk_path(chunked_file, chunk)
  end

  test "adding chunks" do
    chunked_file = new_chunked_file()

    assert {:ok, chunked_file} = ChunkedFile.add_chunk(chunked_file, "test")
    assert {:ok, chunked_file} = ChunkedFile.add_chunk(chunked_file, "test")
    assert 2 == length(chunked_file.chunks)
    assert {:ok, _} = File.stat(@chunk_path)
    assert {:ok, _} = File.stat(@chunk_path_1)
  end

  test "writing chunks" do
    chunked_file = new_chunked_file()
    {:ok, chunk} = Chunk.new(0, "test")

    assert {:ok, chunked_file} = ChunkedFile.write_chunk(chunked_file, chunk)
    assert 1 == length(chunked_file.chunks)
    assert {:ok, _} = File.stat(@chunk_path)
  end

  test "commiting ChunkedFile" do
    chunked_file = new_chunked_file()

    {:ok, chunked_file} = ChunkedFile.add_chunk(chunked_file, "hello ")
    {:ok, chunked_file} = ChunkedFile.add_chunk(chunked_file, "world")
    assert {:ok, path} = ChunkedFile.commit(chunked_file)
    assert @writeable_file_path = path
    assert {:ok, "hello world"} = File.read(@writeable_file_path)
  end

  test "removing chunks" do
    chunked_file = new_chunked_file()
    {:ok, chunked_file} = ChunkedFile.add_chunk(chunked_file, "hello ")
    {:ok, chunked_file} = ChunkedFile.add_chunk(chunked_file, "world")

    assert {:ok, _} = ChunkedFile.remove_chunk(chunked_file, 0)
    {:ok, _} = ChunkedFile.commit(chunked_file)
    assert {:ok, "world"} = File.read(@writeable_file_path)
  end

  test "writeable?" do
    chunked_file = new_chunked_file()
    assert true = ChunkedFile.writeable?(chunked_file)
  end

  test "removing ChunkedFile" do
    chunked_file = new_chunked_file()
    
    assert {:ok, _} = ChunkedFile.remove(chunked_file)
    assert {:error, :enoent} = File.stat(chunked_file.chunked_path)
  end

  defp new_chunked_file() do
    {:ok, chunked_file} = Chunker.new(@writeable_file_path)
    chunked_file
  end

  defp new_chunk() do
    {:ok, chunk} = Chunk.new(0, "test")
    chunk
  end
end