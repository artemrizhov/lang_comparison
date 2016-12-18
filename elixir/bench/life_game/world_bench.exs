defmodule LifeGame.WorldBench do
  use Benchfella

  alias LifeGame.World
  import LifeGame.Utils, only: [str_to_grid: 1]

  # Glider.
  @world %World{width: 6, height: 6, grid: str_to_grid("""
    - - - - - -
    - - # - - -
    - - - # - -
    - # # # - -
    - - - - - -
    - - - - - -
    """)}

  bench "next_step/1 for Glider figure" do
    World.next_step(@world)
  end
end