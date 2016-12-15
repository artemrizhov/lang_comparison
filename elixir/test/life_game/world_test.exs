defmodule LifeGame.WorldTest do
  use ExUnit.Case, async: true
  doctest LifeGame.World

  alias LifeGame.World, as: World

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

  def str_to_grid(str) when is_binary(str) do
    allowed_chars = [_dead, alive] = '-#'
    str
    |> String.to_charlist
    |> Stream.filter(fn x -> x in allowed_chars end) # Filter formatting.
    |> Enum.map(fn x -> x == alive end)  # Convert to boolean.
    |> List.to_tuple
  end

  test "create_random/3" do
    world = World.create_random(3, 2, 0)
    assert %World{width: 3, height: 2, grid: grid} = world
    assert grid == {false, false, false, false, false, false}

    world = World.create_random(3, 2, 1)
    assert %World{width: 3, height: 2, grid: grid} = world
    assert grid == {true, true, true, true, true, true}
  end

  test "neighbours/2" do
    world = %World{width: 4, height: 3}
    # The order of elements is not important.
    assert Enum.sort(World.neighbours(world, {0, 0})) == Enum.sort(
      [{3, 2}, {0, 2}, {1, 2}, {3, 0}, {1, 0}, {3, 1}, {0, 1}, {1, 1}])
    assert Enum.sort(World.neighbours(world, {3, 2})) == Enum.sort(
      [{2, 1}, {3, 1}, {0, 1}, {2, 2}, {0, 2}, {2, 0}, {3, 0}, {0, 0}])
  end

  test "cell_alive?/2" do
    world = %World{width: 2, height: 1, grid: {true, false}}
    # The order of elements is not important.
    assert World.cell_alive?(world, {0, 0})
    assert not World.cell_alive?(world, {1, 0})
  end
end
