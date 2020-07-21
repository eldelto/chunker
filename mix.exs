defmodule Chunker.MixProject do
  use Mix.Project

  def project do
    [
      app: :chunker,
      version: "0.12.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: "https://github.com/eldelto/chunker"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22.2", only: :dev, runtime: false},
      {:credo, "~> 1.4", only: :dev, runtime: false}
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
        "Github" => "https://github.com/eldelto/chunker"
      },
      maintainers: ["Dominic Aschauer"]
    ]
  end
end
