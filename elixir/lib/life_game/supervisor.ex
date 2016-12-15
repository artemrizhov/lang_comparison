defmodule LifeGame.Supervisor do
  use Supervisor

  @name LifeGame.Supervisor

  def start_link do
    ret_val = Supervisor.start_link(__MODULE__, :ok, name: @name)
    Supervisor.start_child(@name, [])
    ret_val
  end

  def init(:ok) do
    children = [
      worker(LifeGame.World, [LifeGame.World], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
