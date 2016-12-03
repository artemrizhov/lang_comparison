"""
The Game of Life implemented in object-oriented style.
https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
"""

__author__ = 'Artem Rizhov'

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
    game = LifeGame(WIDTH, HEIGHT, CELL_SIZE)
    game.run()


class LifeGame(object):

    def __init__(self, width, height, cell_size):
        self.screen = Screen(width * cell_size, height * cell_size)
        self.grid = Grid(width, height, cell_size)
        self.grid.init_random()

    def run(self):
        while not self.is_interrupted():
            self.grid.render(self.screen)
            sleep(INTERVAL)
            self.make_step()

    def make_step(self):
        """ Make next step in the game time """
        # Save old state.
        for row in self.grid:
            for cell in row:
                cell.save_state()
        # Calculate new state.
        for y in range(self.grid.height):
            for x in range(self.grid.width):
                cell = self.grid[y][x]
                cell.calc_state(self.grid.get_neighbours(x, y))

    def is_interrupted(self):
        return pygame.QUIT in (event.type for event in pygame.event.get())


class Grid(list):

    def __init__(self, width, height, cell_size):
        # Define new unpopulated grid as a two-dimensional array of cells.
        super(Grid, self).__init__(
            [Cell(False) for x in range(width)] for y in range(height)
        )

        self.width = width
        self.height = height
        self.cell_size = cell_size

    def init_random(self):
        """
        Init grid with random state

        Each cell is set to the "populated" state with probability
        ``INIT_DENSITY``.
        """
        for row in self:
            for x in range(self.width):
                row[x].alive = random() < INIT_DENSITY

    def get_neighbours(self, x, y):
        y1, y2, y3 = y - 1, y, y + 1
        if y == 0:
            y1 = self.height - 1
        elif y == self.height - 1:
            y3 = 0
        x1, x2, x3 = x - 1, x, x + 1
        if x == 0:
            x1 = self.width - 1
        elif x == self.width - 1:
            x3 = 0

        return (self[y1][x1], self[y1][x2], self[y1][x3],
                self[y2][x1], self[y2][x3],
                self[y3][x1], self[y3][x2], self[y3][x3])

    def render(self, screen):
        screen.clear()
        # Draw the grid.
        for y, row in enumerate(self):
            for x, cell in enumerate(row):
                cell.render(screen, x, y, self.cell_size)
        screen.update()


class Cell(object):

    def __init__(self, alive):
        self.alive = alive

    def save_state(self):
        self.was_alive = self.alive

    def calc_state(self, neighbours):
        # Count populated neighbours.
        alive_count = sum(1 for cell in neighbours if cell.was_alive)

        # Choice new value.
        if self.alive:
            self.alive = 2 <= alive_count <= 3
        else:
            self.alive = alive_count == 3

    def render(self, screen, x, y, cell_size):
        if self.alive:
            screen.draw_rectangle(
                CELL_COLOR, x * cell_size, y * cell_size, cell_size, cell_size)


class Screen(object):

    def __init__(self, width, height):
        self.pygame_screen = pygame.display.set_mode(
            (width, height))

    def clear(self):
        self.pygame_screen.fill(BG_COLOR)

    def update(self):
        pygame.display.flip()

    def draw_rectangle(self, color, x, y, width, height):
        self.pygame_screen.fill(color, (x, y, width, height))


if __name__ == "__main__":
    # execute only if run as a script
    main()
