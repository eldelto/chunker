defmodule Chunker.AlreadyClosedError do
  defexception message: "The given file has already been closed."
end

defmodule Chunker.InvalidIndexError do
  defexception message: "The given index does not point to a valid chunk."
end

defmodule Chunker.ReadOnlyError do
  defexception message: "The given file is read-only."
end
