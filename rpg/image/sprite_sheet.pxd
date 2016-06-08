from rpg.sdl cimport Texture
from rpg.SDL2 cimport SDL_Rect
from rpg.gfx.blitter cimport TextureRect


cdef class SpriteSheet:
    cdef:
       Texture texture
       int sprite_width
       int sprite_height
       int width
       int height

    cdef TextureRect get_tile_by_id(self, int tile_id)
    cdef TextureRect get_tile_by_xy(self, int x, int y)

    cdef inline int _width(self):
        return self.texture.width / self.sprite_width

    cdef inline int _height(self):
        return self.texture.height / self.sprite_height
