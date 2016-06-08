# cython: cdivision=True
from cpython cimport array
import array

from rpg.gfx.blitter cimport Blitter, TextureRect
from rpg.image.sprite_sheet cimport SpriteSheet
from rpg.sdl cimport Texture


cdef class Tileset(SpriteSheet):
    def __init__(self, Texture texture, int tilesize):
        SpriteSheet.__init__(self, texture, tilesize, tilesize)


cdef class Matrix:
    def __cinit__(self, data):
        if data:
            self.shift = len(data[0])
        flattened = []
        for row in data:
            flattened.extend(row)
        self.data = array.array('i', flattened)
        self.ptr = <int*>self.data.data.as_voidptr


cdef class Cube:
    def __cinit__(self, data):
        self.width = len(data)
        if data:
            self.height = len(data[0])
            if data[0]:
                self.depth = len(data[0][0])
            else:
                self.depth = 0
        else:
            self.height = 0
            self.depth = 0
        flattened = [0] * (self.width * self.height * self.depth)
        for x, row in enumerate(data):
            for y, cell in enumerate(row):
                for z, value in enumerate(cell):
                   flattened[self._index(x, y, z)] = value

        self.data = array.array('i', flattened)
        self.ptr = <int*>self.data.data.as_voidptr


cdef class Map:
    def __init__(self, Tileset tileset, int width, int height, int draw_width, int draw_height, data):
        assert tileset is not None
        assert width > 0
        assert height > 0
        self.tileset = tileset
        self.width = width
        self.height = height
        self.draw_width = draw_width
        self.draw_height = draw_height
        self.data = Cube(data)

    cdef draw(self, Blitter blitter, int x, int y):
        cdef int tilesize = self.tileset.tilesize()
        cdef int draw_x_start = max(x / tilesize, 0)
        cdef int draw_x_end = min(draw_x_start + self.draw_width / tilesize, self.width)
        cdef int draw_y_start = max(y / tilesize, 0)
        cdef int draw_y_end = min(draw_y_start + self.draw_height / tilesize, self.height)
        cdef int current_x, current_y, current_z
        # cdef TextureRect tex_rect

        for current_x in range(draw_x_start, draw_x_end):
            for current_y in range(draw_y_start, draw_y_end):
                for current_z in range(self.data.depth):
                    tile_id = self.data.at(current_x, current_y, current_z)
                    if tile_id > 0:
                        tex_rect = self.tileset.get_tile_by_id(tile_id)
                        blitter.blit_rect_to(
                            tex_rect,
                            tilesize * current_x - x,
                            tilesize * current_y - y
                        )




