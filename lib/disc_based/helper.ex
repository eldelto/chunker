defmodule Chunker.DiscBased.Helper do
  alias Chunker.InvalidIndexError

  def file_stream(path) do
    file = File.stream!(path, [:append], 4096)
    {:ok, file}
  rescue
    e in RuntimeError -> {:error, e}
  end

  def write_chunk_map(chunked_file, chunks) do
    content = Enum.join(chunks, ",")
    File.write(chunk_map_path(chunked_file), content)
  end

  def read_chunk_map(chunked_file) do
    # TODO:
    case File.read(chunk_map_path(chunked_file)) do
      {:ok, content} -> string_to_integer_list(content)
      err -> err
    end
  end

  defp chunk_map_path(chunked_file) do
    Path.join(chunked_file.chunked_path, "chunk_map")
  end

  def chunk_path(chunked_file, index) when is_integer(index) and index >= 0 do
    # TODO: Return error when the index is not in chunks.
    Path.join(chunked_file.chunked_path, to_string(index) <> ".chunk")
  end

  def mapped_chunk_path(chunked_file, chunks, index) when is_integer(index) and index >= 0 do
    case Enum.fetch(chunks, index) do
      {:ok, chunk_index} -> {:ok, chunk_path(chunked_file, chunk_index)}
      :error -> {:error, %InvalidIndexError{}}
    end
  end

  def add_chunk(chunked_file, data, index, chunk_map_modifier) when is_integer(index) do
    with {:ok, chunks} <- read_chunk_map(chunked_file),
         chunk_index <- next_chunk_index(chunks),
         chunk_path = chunk_path(chunked_file, chunk_index),
         :ok <- File.write(chunk_path, data),
         new_chunks <- chunk_map_modifier.(chunks, chunk_index, index) do
      write_chunk_map(chunked_file, new_chunks)
    else
      err -> err
    end
  end

  ## Helper fucntions ##
  defp next_chunk_index(chunks) do
    Enum.max(chunks, fn -> -1 end) + 1
  end

  defp string_split(string, delimiter) do
    case String.split(string, delimiter) do
      [""] -> []
      result -> result
    end
  end

  defp string_to_integer_list(string) do
    string_list = string_split(string, ",")

    int_list =
      string_list
      |> Enum.map(&Integer.parse(&1))
      |> Enum.map(fn x ->
        case x do
          {int, _} -> int
          err -> err
        end
      end)

    if Enum.any?(int_list, &(!is_integer(&1))) do
      {:error, "Integer could not be parsed."}
    else
      {:ok, int_list}
    end
  end
end
