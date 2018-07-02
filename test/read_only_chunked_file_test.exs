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

  test "inserting chunk" do
    chunked_file = new_chunked_file()
    assert read_only?(ChunkedFile.insert_chunk(chunked_file, nil, 0))
  end

  test "getting chunk" do
    chunked_file = new_chunked_file()
    
    assert {:ok, "This"} = ChunkedFile.chunk(chunked_file, 0)
    assert {:ok, " is "} = ChunkedFile.chunk(chunked_file, 1)
    assert {:ok, "a te"} = ChunkedFile.chunk(chunked_file, 2)
    assert {:error, _} = ChunkedFile.chunk(chunked_file, 100)
  end

  test "getting chunk list" do
    chunked_file = new_chunked_file()

    assert {:ok, chunks} = ChunkedFile.chunks(chunked_file)
    assert 15 == length(chunks)
  end

  test "removing chunk" do
    chunked_file = new_chunked_file()
    assert read_only?(ChunkedFile.remove_chunk(chunked_file, 0))
  end

  test "writeable?" do
    chunked_file = new_chunked_file()
    assert false == ChunkedFile.writeable?(chunked_file)
  end

  test "path" do
    chunked_file = new_chunked_file()
    assert @readable_file_path = ChunkedFile.path(chunked_file)
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