defmodule LifeGame do
  use Application

  def start(_type, _args) do
    LifeGame.Supervisor.start_link
  end
end
