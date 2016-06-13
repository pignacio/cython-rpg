from cpython cimport array
import array

from rpg.SDL2 cimport SDL_Rect
from rpg.gfx.blitter cimport Blitter, TextureRect
from rpg.image.sprite_sheet cimport SpriteSheet
from rpg.sdl cimport KeyboardState
from rpg.types cimport Point, IntPoint


cdef class Tileset(SpriteSheet):
    cdef inline int tilesize(self):
        return self.sprite_height


cdef class Matrix:
    cdef int shift
    cdef array.array data
    cdef int* ptr

    cdef inline int at(self, int x, int y):
        return self.ptr[x * self.shift + y]


cdef class Cube:
    cdef int width
    cdef int height
    cdef int depth
    cdef array.array data
    cdef int* ptr

    cdef inline int _index(self, int x, int y, int z):
        return x * self.depth * self.height + y * self.depth + z

    cdef inline void set(self, int x, int y, int z, int value):
        self.ptr[self._index(x, y, z)] = value

    cdef inline int at(self, int x, int y, int z):
        return self.ptr[self._index(x, y, z)]


cdef struct Actor:
    TextureRect image
    Point position
    SDL_Rect collision_box
    IntPoint last_direction


cdef class Map:
    cdef:
        Tileset tileset
        int width
        int height
        int draw_width
        int draw_height
        Cube data
        Actor main_actor

    cdef draw(self, Blitter blitter, int x, int y)
    cdef process(self, int ticks, KeyboardState keyboard_state)
