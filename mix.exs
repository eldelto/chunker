defmodule Chunker.MixProject do
  use Mix.Project

  def project do
    [
      app: :chunker,
      version: "0.12.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://gitlab.com/eldelto/chunker"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 0.6", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19.0", only: :dev, runtime: false},
      {:credo, "~> 0.10.2", only: :dev, runtime: false}
    ]
  end

  # Project description.
  defp description do
    "A library to deal with files in chunks (e.g. chunked file upload)."
  end

  # Package metadata.
  defp package do
    [
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/elixir-ecto/postgrex",
        "Online documentation" => "https://hexdocs.pm/chunker"
      }
    ]
  end
end
