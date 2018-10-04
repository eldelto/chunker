defmodule Chunker do
  alias Chunker.ChunkedFile

  defdelegate append_chunk(chunked_file, data), to: ChunkedFile

  defdelegate insert_chunk(chunked_file, data, index), to: ChunkedFile

  defdelegate remove_chunk(chunked_file, index), to: ChunkedFile

  defdelegate chunk(chunked_file, index), to: ChunkedFile

  defdelegate chunks(chunked_file), to: ChunkedFile

  defdelegate commit(chunked_file), to: ChunkedFile

  defdelegate writeable?(chunked_file), to: ChunkedFile

  defdelegate path(chunked_file), to: ChunkedFile

  defdelegate remove(chunked_file), to: ChunkedFile

  defdelegate close(chunked_file), to: ChunkedFile

  defdelegate closed?(chunked_file), to: ChunkedFile
end
