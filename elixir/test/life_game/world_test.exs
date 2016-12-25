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
    screen_before = LifeGame.Screen.init("Before", width * 20, height * 20)
    screen_after = LifeGame.Screen.init("After", width * 20, height * 20)
    screen_error = LifeGame.Screen.init("Error", width * 20, height * 20)
    world = World.next_step(world_before)
#    LifeGame.Screen.update screen_before, {255, 255, 255}, &(World.render &1, world_before, 20, {0, 100, 0})
#    LifeGame.Screen.update screen_after, {255, 255, 255}, &(World.render &1, world_after, 20, {0, 100, 0})
#    LifeGame.Screen.update screen_error, {255, 255, 255}, &(World.render &1, world, 20, {0, 100, 0})
#    Process.sleep 100000
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
    assert World.is_alive(true) == not World.is_alive(false)
  end
end
