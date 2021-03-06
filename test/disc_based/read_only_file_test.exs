defmodule Chunker.DiscBased.ReadOnlyFileTest do
  use ExUnit.Case

  alias Chunker.DiscBased
  alias Chunker.DiscBased.ReadOnlyFile
  alias Chunker.ReadOnlyError

  doctest ReadOnlyFile

  @readable_file_path "test/resources/tmp/test_file.txt"

  setup do
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

    assert {:ok, "This"} = Chunker.get_chunk(chunked_file, 0)
    assert {:ok, " is "} = Chunker.get_chunk(chunked_file, 1)
    assert {:ok, "a te"} = Chunker.get_chunk(chunked_file, 2)
    assert {:error, _} = Chunker.get_chunk(chunked_file, 100)
  end

  test "getting chunk length" do
    chunked_file = new_chunked_file()

    assert {:ok, 15} = Chunker.length(chunked_file)
  end

  test "removing chunk" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.remove_chunk(chunked_file, 0))
  end

  test "prepending chunk" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.prepend_chunk(chunked_file, nil))
  end

  test "replacing chunk" do
    chunked_file = new_chunked_file()
    assert read_only?(Chunker.replace_chunk(chunked_file, nil, 0))
  end

  test "writeable?" do
    chunked_file = new_chunked_file()
    assert false == Chunker.writeable?(chunked_file)
  end

  test "removing ChunkedFile" do
    chunked_file = new_chunked_file()

    assert :ok = Chunker.remove(chunked_file)
    assert {:error, :enoent} = File.stat(@readable_file_path)
  end

  test "closing ChunkedFile" do
    chunked_file = new_chunked_file()
    assert :ok = Chunker.close(chunked_file)
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
    result == {:error, %ReadOnlyError{}}
  end
end
