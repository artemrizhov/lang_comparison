defmodule Mix.Tasks.Run.NoHalt do
  use Mix.Task

  def run(args) do
    IO.puts ["NOTE: --no-halt option is applied by default via run.no_halt. ",
             "Type 'mix run' or 'iex -S mix run' to run with halt."]
    Mix.Tasks.Run.run(["--no-halt" | args])
  end
end