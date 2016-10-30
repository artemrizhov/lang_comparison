"""
The Game of Life implemented in procedural style.
https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
"""
import atexit
import curses
from copy import deepcopy
from random import random
from time import sleep


WIDTH = 40
HEIGHT = 20
INTERVAL = 0.1
INIT_DENSITY = 0.3  # From 0 to 1.
POPULATED_CHAR = 'o'


def main(stdscr):
    # Reset terminal from curses mode on exit.
    @atexit.register
    def reset_screen():
        curses.nocbreak()
        if stdscr:
            stdscr.keypad(0)
        curses.echo()
        curses.endwin()

    # Run the game.
    grid = create_grid(WIDTH, HEIGHT)
    init_grid_random(grid)
    while True:
        render(grid, stdscr)
        sleep(INTERVAL)
        make_step(grid)


def create_grid(width, height):
    """
    Create new empty grid

    Returns new unpopulated grid as a two-dimensional array of boolean values.
    ``True`` means "populated", ``False`` means "unpopulated".
    """
    return [[False for x in range(width)] for y in range(height)]


def init_grid_random(grid):
    """
    Init grid with random state

    Each cell is set to the "populated" state with probability
    ``INIT_DENSITY``.
    """
    for row in grid:
        for x in range(len(row)):
            row[x] = random() < INIT_DENSITY


def make_step(grid):
    """ Make next step in the game time """
    old_grid = deepcopy(grid)
    row_len = len(grid[0])
    for y in range(len(grid)):
        for x in range(row_len):
            grid[y][x] = calc_cell(old_grid, y, x)


def calc_cell(grid, y, x):
    """ Calculate the next state of the cell """
    # Count neighbours.
    max_y = len(grid)
    max_x = len(grid[0])
    neighbours = 0
    for ny in range(y - 1, y + 2):
        ny = translate_pos(ny, max_y)
        for nx in range(x - 1, x + 2):
            nx = translate_pos(nx, max_x)
            if grid[ny][nx] and not (ny == y and nx == x):
                neighbours += 1

    # Choice new value.
    if grid[y][x]:
        return 2 <= neighbours <= 3
    else:
        return neighbours == 3


def translate_pos(i, max_i):
    """ If position is not in range then move it to the opposite side """
    if i < 0:
        i += max_i
    elif i >= max_i:
        i -= max_i
    return i


def render(grid, stdscr):
    # Clear the screen.
    stdscr.clear()
    # Prepare the output text.
    output = []
    for y in range(len(grid)):
        row = grid[y]
        for cell in row:
            output.append(POPULATED_CHAR if cell else " ")
        output.append("\n")
    # Output the text.
    stdscr.addstr(0, 0, "".join(output))
    # Make the changes visible.
    stdscr.refresh()


if __name__ == "__main__":
    # execute only if run as a script
    curses.wrapper(main)()
