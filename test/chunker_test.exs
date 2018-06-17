defmodule ChunkerTest do
  use ExUnit.Case

  alias Chunker.Chunk
  alias Chunker.WriteableChunkedFile

  doctest Chunker

  @file_path "test/resources/neuralnetworkprogrammingwithjava.pdf"
  @writeable_file_path "test/resources/tmp/chunked_file.txt"
  @chunk_path "test/resources/tmp/chunked_file.txt.chunked/0.chunk"
  @chunk_path_1 "test/resources/tmp/chunked_file.txt.chunked/1.chunk"

  @tmp_path "test/resources/tmp/*"

  setup do
    on_exit(fn ->
      :os.cmd(to_charlist("rm -rf " <> @tmp_path))
    end)
  end

  @tag :skip
  test "ChunkedFile from path" do
    assert {:ok, %WriteableChunkedFile{}} = Chunker.from(@file_path)
  end

  @tag :skip
  test "ChunkedFile from File.Stream" do
    stream = File.stream!(@file_path)
    assert {:ok, %WriteableChunkedFile{}} = Chunker.from(stream)
  end

  @tag :skip
  test "number of Chunks" do
    chunked_file = get_chunked_file()
    assert {:ok, 5} = chunked_file.chunk_count()
  end

  @tag :skip
  test "chunk enumeration" do
    _ = get_chunked_file()
    assert false
  end

  @tag :skip
  test "chunk streaming" do
    assert false
  end

  test "new ChunkedFile" do
    assert %WriteableChunkedFile{} = new_chunked_file()
  end

  test "get Chunk path" do
    chunked_file = new_chunked_file()
    chunk = new_chunk()
    assert {:ok, @chunk_path} == Chunker.chunk_path(chunked_file, chunk)
  end

  test "adding chunks" do
    chunked_file = new_chunked_file()

    assert {:ok, chunked_file} = Chunker.add_chunk(chunked_file, "test")
    assert {:ok, chunked_file} = Chunker.add_chunk(chunked_file, "test")
    assert 2 == length(chunked_file.chunks)
    assert {:ok, _} = File.stat(@chunk_path)
    assert {:ok, _} = File.stat(@chunk_path_1)
  end

  test "writing chunks" do
    chunked_file = new_chunked_file()
    {:ok, chunk} = Chunk.new(0, "test")

    assert {:ok, chunked_file} = Chunker.write_chunk(chunked_file, chunk)
    assert 1 == length(chunked_file.chunks)
    assert {:ok, _} = File.stat(@chunk_path)
  end

  test "commiting ChunkedFile" do
    chunked_file = new_chunked_file()

    {:ok, chunked_file} = Chunker.add_chunk(chunked_file, "hello ")
    {:ok, chunked_file} = Chunker.add_chunk(chunked_file, "world")
    assert {:ok, path} = Chunker.commit(chunked_file)
    assert @writeable_file_path = path
    assert {:ok, "hello world"} = File.read(@writeable_file_path)
  end

  test "removing chunks" do
    chunked_file = new_chunked_file()
    {:ok, chunked_file} = Chunker.add_chunk(chunked_file, "hello ")
    {:ok, chunked_file} = Chunker.add_chunk(chunked_file, "world")

    assert {:ok, _} = Chunker.remove_chunk(chunked_file, 0)
    {:ok, _} = Chunker.commit(chunked_file)
    assert {:ok, "world"} = File.read(@writeable_file_path)
  end

  @tag :skip
  test "writeable?" do
    assert false
  end

  defp get_chunked_file() do
    Chunker.from(@file_path)
  end

  defp new_chunked_file() do
    {:ok, chunked_file} = WriteableChunkedFile.new(@writeable_file_path)
    chunked_file
  end

  defp new_chunk() do
    {:ok, chunk} = Chunk.new(0, "test")
    chunk
  end
end
