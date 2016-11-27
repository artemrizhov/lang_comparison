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
INTERVAL = 0.01
INIT_DENSITY = 0.1  # From 0 to 1.


def main():
    screen = init_screen(WIDTH, HEIGHT, CELL_SIZE)

    # Run the game.
    grid = create_grid(WIDTH, HEIGHT)
    init_grid_random(grid, WIDTH, HEIGHT)
    while not interrupted():
        render(grid, screen, CELL_SIZE)
        sleep(INTERVAL)
        make_step(grid, WIDTH, HEIGHT)


def create_grid(width, height):
    """
    Create new empty grid

    Returns new unpopulated grid as a two-dimensional array of boolean values.
    ``True`` means "populated", ``False`` means "unpopulated".
    """
    return [[False for x in range(width)] for y in range(height)]


def init_grid_random(grid, width, height):
    """
    Init grid with random state

    Each cell is set to the "populated" state with probability
    ``INIT_DENSITY``.
    """
    for row in grid:
        for x in range(width):
            row[x] = random() < INIT_DENSITY


def make_step(grid, width, height):
    """ Make next step in the game time """
    old_grid = deepcopy(grid)
    for y in range(height):
        for x in range(width):
            grid[y][x] = calc_cell(old_grid, x, y, width, height)


def calc_cell(grid, x, y, width, height):
    """ Calculate the next state of the cell """
    # Count populated neighbours.
    neighbours = sum(1 for nx, ny in get_neighbours(x, y, width, height)
                     if grid[ny][nx])

    # Choice new value.
    if grid[y][x]:
        return 2 <= neighbours <= 3
    else:
        return neighbours == 3


def get_neighbours(x, y, width, height):
    """ Calculates and returns the neighbours coordinates """
    y1, y2, y3 = y - 1, y, y + 1
    if y == 0:
        y1 = height - 1
    elif y == height - 1:
        y3 = 0
    x1, x2, x3 = x - 1, x, x + 1
    if x == 0:
        x1 = width - 1
    elif x == width - 1:
        x3 = 0

    return ((x1, y1), (x1, y2), (x1, y3),
            (x2, y1), (x2, y3),
            (x3, y1), (x3, y2), (x3, y3))


def interrupted():
    return pygame.QUIT in (event.type for event in pygame.event.get())


def init_screen(width, height, cell_size):
    return pygame.display.set_mode((width * cell_size, height * cell_size))


def render(grid, screen, cell_size):
    # Clear the screen.
    screen.fill(BG_COLOR)
    # Draw the grid.
    for y, row in enumerate(grid):
        for x, cell in enumerate(row):
            if cell:
                screen.fill(CELL_COLOR,
                            (x*cell_size, y*cell_size, cell_size, cell_size))
    # Show changes.
    pygame.display.flip()


if __name__ == "__main__":
    # execute only if run as a script
    main()
