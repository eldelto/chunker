defmodule Chunker.AlreadyCommittedError do
  defexception message: "The given file has already been committed."
end

defmodule Chunker.InvalidIndexError do
  defexception message: "The given index does not point to a valid chunk."
end
