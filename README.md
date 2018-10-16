# Chunker

A library to deal with files in chunks (e.g. chunked file upload).

Chunked file uploads are often necessary when dealing with very large files
or it is required to pause and resume a download.

Chunker provides a uniform interface to deal with different implementations of
chunked files.

## Installation

The package can be installed by adding `chunker` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:chunker, "~> 0.10.3"}
  ]
end
```

## Usage

Using the provided default implementation for disc-based chunked files:

```elixir
# Initialize a new disc-based chunked file with a chunk size of 4 byte.
{:ok, chunked_file} = Chunker.DiscBased.new("test.txt", 4)

# Append data to the file.
{:ok, chunked_file} = Chunker.append_chunk(chunked_file, "test")
{:ok, chunked_file} = Chunker.append_chunk(chunked_file, "world")

# Commit the file after all chunks have been appended.
{:ok, chunked_file} = Chunker.commit(chunked_file)

# Read chunks from the file.
{:ok, data} = Chunker.chunk(chunked_file, 1) # data => "world"
```

You can also create a custom implementation of a chunked file (e.g. that is
backed by a database) by implementing the protocol `Chunker.ChunkedFile`:

```elixir
defimpl Chunker.ChunkedFile, for: CustomChunkedFile do
  def append_chunk(chunked_file, data) do
    ...
  end
  
  ...  
end
```
Please refer to the documentation to see which functions are required by the
protocol.

## Documentation

For detailed documentation please visit our HexDocs page: 
[Documentation](https://hexdocs.pm/chunker)
