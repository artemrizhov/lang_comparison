defmodule LifeGame.WorldBench do
  use Benchfella

  alias LifeGame.World
  import LifeGame.Utils, only: [str_to_grid: 1]

  @glider_world %World{width: 6, height: 6, grid: str_to_grid("""
    - - - - - -
    - - # - - -
    - - - # - -
    - # # # - -
    - - - - - -
    - - - - - -
    """)}

  :rand.seed(:exs64, {0, 0, 0})
  @big_random_world World.create_random(1000, 1000, 0.1)

  bench "next_step/1 for Glider figure" do
    World.next_step(@glider_world)
  end

  bench "next_step/1 for big random world" do
    World.next_step(@big_random_world)
  end

  bench "neighbours/2 for small world of Glider" do
    World.neighbours(@glider_world, {0, 0})
  end

  bench "neighbours/2 for big world" do
    World.neighbours(@big_random_world, {0, 0})
  end
end