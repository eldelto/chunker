defmodule WriteableChunkedFileTest do
  use ExUnit.Case

  alias Chunker.ChunkedFile
  alias Chunker.WriteableChunkedFile

  doctest WriteableChunkedFile

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
    assert %WriteableChunkedFile{} = new_chunked_file()
  end

  test "appending chunks" do
    chunked_file = new_chunked_file()

    assert {:ok, _} = ChunkedFile.append_chunk(chunked_file, "test")
    assert {:ok, _} = ChunkedFile.append_chunk(chunked_file, "test")
  
    assert {:ok, _} = File.stat(@chunk_path)
    assert {:ok, _} = File.stat(@chunk_path_1)    
    assert {:ok, "0,1"} = File.read(chunk_map_path(chunked_file))
  end

  test "committing ChunkedFile" do
    chunked_file = new_chunked_file()

    {:ok, _} = ChunkedFile.append_chunk(chunked_file, "hello ")
    {:ok, _} = ChunkedFile.append_chunk(chunked_file, "world")
    assert {:ok, path} = ChunkedFile.commit(chunked_file)
    assert @writeable_file_path = path
    assert {:ok, "hello world"} = File.read(@writeable_file_path)
  end

  test "inserting chunks" do
    chunked_file = new_chunked_file()

    assert {:ok, _} = ChunkedFile.append_chunk(chunked_file, "hello")
    assert {:ok, _} = ChunkedFile.append_chunk(chunked_file, "world")
    assert {:ok, _} = ChunkedFile.insert_chunk(chunked_file, " test ", 1)
  
    assert {:ok, _} = File.stat(@chunk_path)
    assert {:ok, _} = File.stat(@chunk_path_1)
    assert {:ok, _} = File.stat(@chunk_path_2)
    assert {:ok, "0,2,1"} = File.read(chunk_map_path(chunked_file))

    assert {:ok, path} = ChunkedFile.commit(chunked_file)
    assert @writeable_file_path = path
    assert {:ok, "hello test world"} = File.read(@writeable_file_path)
  end

  test "getting chunks" do
    chunked_file = new_chunked_file()

    {:ok, _} = ChunkedFile.append_chunk(chunked_file, "hello")
    {:ok, _} = ChunkedFile.append_chunk(chunked_file, "world")
  
    assert {:ok, "world"} = ChunkedFile.get_chunk(chunked_file, 1)
  end

  test "removing chunks" do
    chunked_file = new_chunked_file()
    {:ok, _} = ChunkedFile.append_chunk(chunked_file, "hello ")
    {:ok, _} = ChunkedFile.append_chunk(chunked_file, "world")

    assert {:ok, _} = ChunkedFile.remove_chunk(chunked_file, 0)    
    {:ok, _} = ChunkedFile.commit(chunked_file)
    assert {:ok, "world"} = File.read(@writeable_file_path)
    assert {:ok, "1"} = File.read(chunk_map_path(chunked_file))
  end

  test "writeable?" do
    chunked_file = new_chunked_file()
    assert true === ChunkedFile.writeable?(chunked_file)
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

  defp chunk_map_path(chunked_file) do
    Path.join(chunked_file.chunked_path, "chunk_map")
  end
end