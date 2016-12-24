defmodule LifeGame.Mixfile do
  use Mix.Project

  def project do
    [app: :life_game,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     default_task: "run.no_halt",
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger],
     mod: {LifeGame, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:benchfella, "~> 0.3", only: [:dev, :test]},
      {:benchee, "~> 0.6", only: :dev}
    ]
  end
end
