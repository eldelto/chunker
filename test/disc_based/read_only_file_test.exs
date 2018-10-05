defmodule Chunker.DiscBased.ReadOnlyFileTest do
  use ExUnit.Case

  alias Chunker.DiscBased
  alias Chunker.DiscBased.ReadOnlyFile

  doctest ReadOnlyFile

  @readable_file_path "test/resources/tmp/test_file.txt"

  setup_all do
    File.write(@readable_file_path, "This is a test file which contains some text to read from.")
  end

  test "new ChunkedFile" do
    assert %ReadOnlyFile{} = new_chunked_file()
  end

  test "appending chunks" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.append_chunk(chunked_file, nil))
  end

  test "committing ChunkedFile" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.commit(chunked_file))
  end

  test "inserting chunk" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.insert_chunk(chunked_file, nil, 0))
  end

  test "getting chunk" do
    chunked_file = new_chunked_file()

    assert {:ok, "This"} = Chunker.chunk(chunked_file, 0)
    assert {:ok, " is "} = Chunker.chunk(chunked_file, 1)
    assert {:ok, "a te"} = Chunker.chunk(chunked_file, 2)
    assert {:error, _} = Chunker.chunk(chunked_file, 100)
  end

  test "getting chunk list" do
    chunked_file = new_chunked_file()

    assert {:ok, chunks} = Chunker.chunks(chunked_file)
    assert 15 == length(chunks)
  end

  test "removing chunk" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.remove_chunk(chunked_file, 0))
  end

  test "writeable?" do
    chunked_file = new_chunked_file()
    assert false == Chunker.writeable?(chunked_file)
  end

  test "path" do
    chunked_file = new_chunked_file()
    assert @readable_file_path = Chunker.path(chunked_file)
  end

  test "removing ChunkedFile" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.remove(chunked_file))
  end

  test "closing ChunkedFile" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.close(chunked_file))
  end

  test "closed?" do
    chunked_file = new_chunked_file()
    assert false === Chunker.closed?(chunked_file)
  end

  defp new_chunked_file do
    {:ok, chunked_file} = DiscBased.new(@readable_file_path, 4)
    chunked_file
  end

  defp read_only?(result) do
    result == {:error, "This ChunkedFile is read-only."}
  end
end
