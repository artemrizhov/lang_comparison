defmodule LifeGame.WorldTest do
  use ExUnit.Case, async: true
  doctest LifeGame.World

  alias LifeGame.World
  import LifeGame.Utils, only: [str_to_grid: 1]

  test "next_step/1" do
    # Primitive field.
    world_before = %World{width: 1, height: 1, grid: {false}}
    assert World.next_step(world_before) == world_before

    # Topical figures.
    world_before = %World{width: 35, height: 6, grid: str_to_grid("""
       Glider       Blinker             Beacon           Block    Beehive
      - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      - - # - - - - - - - - # - - # # - - - - # # - - - - # # - - - # # - -
      - - - # - - # # # - - # - - # - - - - - # # - - - - # # - - # - - # -
      - # # # - - - - - - - # - - - - - # - - - - # # - - - - - - - # # - -
      - - - - - - - - - - - - - - - - # # - - - - # # - - - - - - - - - - -
      - - - - - - - # - - - - - - - - - - - - - - - - - - - - - - - - - - -
    """)}
    world_after = %World{width: 35, height: 6, grid: str_to_grid("""
       Glider       Blinker             Beacon           Block    Beehive
      - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      - - - - - - - # - - - - - - # # - - - - # # - - - - # # - - - # # - -
      - # - # - - - # - - # # # - # # - - - - # - - - - - # # - - # - - # -
      - - # # - - - # - - - - - - - - # # - - - - - # - - - - - - - # # - -
      - - # - - - - - - - - - - - - - # # - - - - # # - - - - - - - - - - -
      - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    """)}
    assert World.next_step(world_before) == world_after

    # Boundaries.
    world_before = %World{width: 5, height: 5, grid: str_to_grid(
      "# # - - #    - - - - -    - - - - -    - - - - -    - - - - -")}
    world_after = %World{width: 5, height: 5, grid: str_to_grid(
      "# - - - -    # - - - -    - - - - -    - - - - -    # - - - -")}
    assert World.next_step(world_before) == world_after
    world_before = %World{width: 5, height: 5, grid: str_to_grid(
      "- - - - -    - - - - -    - - - - -    - - - - -    # - - # #")}
    world_after = %World{width: 5, height: 5, grid: str_to_grid(
      "- - - - #    - - - - -    - - - - -    - - - - #    - - - - #")}
    assert World.next_step(world_before) == world_after
  end

  test "create_random/3" do
    world = World.create_random(3, 2, 0)
    assert %World{width: 3, height: 2, grid: grid} = world
    assert grid == {false, false, false, false, false, false}

    world = World.create_random(3, 2, 1)
    assert %World{width: 3, height: 2, grid: grid} = world
    assert grid == {true, true, true, true, true, true}
  end

  test "is_alive/2" do
    import World
    world = %World{width: 2, height: 1, grid: {true, false}}
    # The order of elements is not important.
    assert World.is_alive(world, {0, 0})
    assert not World.is_alive(world, {1, 0})
  end

  test "is_alive/1" do
    assert World.is_alive(true) == not World.is_alive(false)
  end
end
