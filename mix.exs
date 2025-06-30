defmodule Taskbeam.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :taskbeam,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings"
      ],

      # Hex
      description: description(),
      package: package(),

      # Docs
      name: "Taskbeam",
      source_url: "https://github.com/croesnick/taskbeam",
      homepage_url: "https://github.com/croesnick/taskbeam",
      docs: [
        main: "Taskbeam",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help escript.build" to learn about building escripts.
  defp escript do
    [
      main_module: Taskbeam.CLI.Main,
      name: "taskbeam"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.4.0"},
      {:jason, "~> 1.4"},
      {:optimus, "~> 0.2.0"},
      {:table_rex, "~> 4.0.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    "A modern Elixir API client for Todoist with full Sync API support, typed structs, and CLI tool"
  end

  defp package do
    [
      name: "taskbeam",
      files: ~w(lib priv mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/croesnick/taskbeam",
        "Changelog" => "https://github.com/croesnick/taskbeam/blob/main/CHANGELOG.md"
      },
      maintainers: ["croesnick"]
    ]
  end
end
