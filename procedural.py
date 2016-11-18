"""
The Game of Life implemented in procedural style.
https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
"""
from copy import deepcopy
from random import random
from time import sleep

import pygame


WIDTH = 300
HEIGHT = 300
CELL_SIZE = 5
BG_COLOR = 255, 255, 255
CELL_COLOR = 0, 100, 0
INTERVAL = 0.1
INIT_DENSITY = 0.1  # From 0 to 1.


def main():
    screen = init_screen(WIDTH, HEIGHT, CELL_SIZE)

    # Run the game.
    grid = create_grid(WIDTH, HEIGHT)
    init_grid_random(grid)
    while not interrupted():
        render(grid, screen, CELL_SIZE)
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
    y_len = len(grid)
    x_len = len(grid[0])
    y_range = list(range(y - 1, y + 2))
    if y == 0:
        y_range[0] = y_len - 1
    elif y == y_len - 1:
        y_range[2] = 0
    x_range = list(range(x - 1, x + 2))
    if x == 0:
        x_range[0] = x_len - 1
    elif x == x_len - 1:
        x_range[2] = 0

    neighbours = (
        int(grid[y_range[0]][x_range[0]]) +
        int(grid[y_range[0]][x_range[1]]) +
        int(grid[y_range[0]][x_range[2]]) +
        int(grid[y_range[1]][x_range[0]]) +
        int(grid[y_range[1]][x_range[2]]) +
        int(grid[y_range[2]][x_range[0]]) +
        int(grid[y_range[2]][x_range[1]]) +
        int(grid[y_range[2]][x_range[2]])
    )

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


def interrupted():
    return pygame.QUIT in (event.type for event in pygame.event.get())


def init_screen(width, height, cell_size):
    return pygame.display.set_mode((width * cell_size, height * cell_size))


def render(grid, screen, cell_size):
    # Clear the screen.
    screen.fill(BG_COLOR)
    # Draw the grid.
    size = cell_size
    for y, row in enumerate(grid):
        for x, cell in enumerate(row):
            if cell:
                screen.fill(CELL_COLOR,
                            (x*size, y*size, size, size))
    # Output the text.
    pygame.display.flip()


if __name__ == "__main__":
    # execute only if run as a script
    main()
