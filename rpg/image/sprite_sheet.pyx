import cython

from rpg.logutils cimport log_info
from rpg.sdl cimport Texture
from rpg.SDL2 cimport SDL_Rect
from rpg.gfx.blitter cimport TextureRect


cdef class SpriteSheet:
    def __init__(self, Texture texture, int sprite_width, int sprite_height):
        assert texture is not None
        assert  0 < sprite_width <= texture.width
        assert  0 < sprite_height <= texture.height
        self.texture = texture
        self.sprite_width = sprite_width
        self.sprite_height = sprite_height
        self.width = self._width()
        self.height = self._height()
        log_info("Creating SpriteSheet(%dx%d) from Texture[%p]. Size: %d x %d",
                 sprite_width, sprite_height, texture.ptr,
                 self.width, self.height)

    cdef TextureRect get_tile_by_id(self, int tile_id):
        assert 0 <= tile_id < self.width * self.height
        with cython.cdivision(True):
            return self.get_tile_by_xy(tile_id % self.width, tile_id / self.width)

    cdef TextureRect get_tile_by_xy(self, int x, int y):
        assert 0 <= x < self.width
        assert 0 <= y < self.height
        return TextureRect(self.texture.ptr, SDL_Rect(
            self.sprite_width * x,
            self.sprite_height * y,
            self.sprite_width,
            self.sprite_height
        ))
