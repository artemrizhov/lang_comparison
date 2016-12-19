defmodule LifeGame.WorldTest do
  use ExUnit.Case, async: true
  doctest LifeGame.World

  alias LifeGame.World
  import LifeGame.Utils, only: [str_to_grid: 3]

  test "next_step/1" do
    # Primitive field.
    world_before = %World{width: 1, height: 1, grid: str_to_grid(1, 1, "-")}
    assert World.next_step(world_before) == world_before

    # Topical figures.
    {width, height} = {35, 6}
    grid = str_to_grid(width, height, """
       Glider       Blinker             Beacon           Block    Beehive
      - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      - - # - - - - - - - - # - - # # - - - - # # - - - - # # - - - # # - -
      - - - # - - # # # - - # - - # - - - - - # # - - - - # # - - # - - # -
      - # # # - - - - - - - # - - - - - # - - - - # # - - - - - - - # # - -
      - - - - - - - - - - - - - - - - # # - - - - # # - - - - - - - - - - -
      - - - - - - - # - - - - - - - - - - - - - - - - - - - - - - - - - - -
    """)
    world_before = %World{width: width, height: height, grid: grid}
    grid = str_to_grid(width, height, """
       Glider       Blinker             Beacon           Block    Beehive
      - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      - - - - - - - # - - - - - - # # - - - - # # - - - - # # - - - # # - -
      - # - # - - - # - - # # # - # # - - - - # - - - - - # # - - # - - # -
      - - # # - - - # - - - - - - - - # # - - - - - # - - - - - - - # # - -
      - - # - - - - - - - - - - - - - # # - - - - # # - - - - - - - - - - -
      - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    """)
    world_after = %World{width: 35, height: 6, grid: grid}
    assert World.next_step(world_before) == world_after

    # Boundaries.
    {width, height} = {5, 5}
    world_before = %World{width: width, height: width, grid: str_to_grid(
      width, height, "# # - - #  - - - - -  - - - - -  - - - - -  - - - - -")}
    world_after = %World{width: width, height: width, grid: str_to_grid(
      width, height, "# - - - -  # - - - -  - - - - -  - - - - -  # - - - -")}
    assert World.next_step(world_before) == world_after
    world_before = %World{width: width, height: width, grid: str_to_grid(
      width, height, "- - - - -  - - - - -  - - - - -  - - - - -  # - - # #")}
    world_after = %World{width: width, height: width, grid: str_to_grid(
      width, height, "- - - - #  - - - - -  - - - - -  - - - - #  - - - - #")}
    assert World.next_step(world_before) == world_after
  end

  test "create_random/3" do
    world = World.create_random(3, 2, 0)
    assert %World{width: 3, height: 2, grid: grid} = world
    assert grid == str_to_grid(3, 2, "- - - - - -")

    world = World.create_random(3, 2, 1)
    assert %World{width: 3, height: 2, grid: grid} = world
    assert grid == str_to_grid(3, 2, "# # # # # #")
  end

  test "is_alive/1" do
    assert World.is_alive(true)
    assert not World.is_alive(false)
  end
end
