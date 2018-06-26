defmodule ReadOnlyChunkedFileTest do
  use ExUnit.Case

  alias Chunker.ChunkedFile
  alias Chunker.ReadOnlyChunkedFile

  doctest ReadOnlyChunkedFile

  @readable_file_path "test/resources/tmp/test_file.txt"

  setup_all do
    File.write(@readable_file_path, "This is a test file which contains some text to read from.")
  end

  test "new ChunkedFile" do
    assert %ReadOnlyChunkedFile{} = new_chunked_file()
  end

  test "appending chunks" do
    chunked_file = new_chunked_file()
    assert read_only?(ChunkedFile.append_chunk(chunked_file, nil))
  end

  test "committing ChunkedFile" do
    chunked_file = new_chunked_file()
    assert read_only?(ChunkedFile.commit(chunked_file))
  end

  test "inserting chunks" do
    chunked_file = new_chunked_file()
    assert read_only?(ChunkedFile.insert_chunk(chunked_file, nil, 0))
  end

  test "getting chunks" do
    chunked_file = new_chunked_file()
    
    assert {:ok, "This"} = ChunkedFile.get_chunk(chunked_file, 0)
    assert {:ok, " is "} = ChunkedFile.get_chunk(chunked_file, 1)
    assert {:ok, "a te"} = ChunkedFile.get_chunk(chunked_file, 2)
  end

  test "removing chunks" do
    chunked_file = new_chunked_file()
    assert read_only?(ChunkedFile.remove_chunk(chunked_file, 0))
  end

  test "writeable?" do
    chunked_file = new_chunked_file()
    assert false == ChunkedFile.writeable?(chunked_file)
  end

  test "removing ChunkedFile" do
    chunked_file = new_chunked_file()
    assert read_only?(ChunkedFile.remove(chunked_file))
  end

  defp new_chunked_file() do
    {:ok, chunked_file} = Chunker.new(@readable_file_path)
    chunked_file
  end

  defp read_only?(result) do
    result == {:error, "This ChunkedFile is read-only."}
  end
end