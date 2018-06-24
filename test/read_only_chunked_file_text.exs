defmodule ReadOnlyChunkedFileTest do
  use ExUnit.Case

  doctest ReadOnlyChunkedFile

  @readable_file_path "test/resources/tmp/test_file.txt"

  setup_all do
    File.write(@readable_file_path, "This is a test file which contains some text to read from.")
  end
end