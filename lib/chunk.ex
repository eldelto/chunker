defmodule Chunker.Chunk do
  defstruct index: nil, data: nil

  def new(index, data) do
    {:ok, %__MODULE__{index: index, data: data}}
  end
end
