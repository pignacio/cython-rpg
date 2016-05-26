from rpg.SDL2 cimport (
    SDL_Texture,
    SDL_Rect,
)
from rpg.sdl cimport (
    Renderer,
)


cdef struct TextureRect:
    SDL_Texture* texture
    SDL_Rect rect


cdef class Blitter:
    cdef Renderer renderer

    cdef inline void blit_rect_to(self, TextureRect rect, int x, int y):
        cdef SDL_Rect dest = SDL_Rect(
            x,
            y,
            rect.rect.w,
            rect.rect.h,
        )
        self.blit_rect_to_rect(rect, &dest)

    cdef inline void blit_rect_to_rect(self, TextureRect rect, const SDL_Rect* dest):
        self.blit_full(rect.texture, &rect.rect, dest)

    cdef inline void blit_full(self, SDL_Texture* texture, const SDL_Rect* src, const SDL_Rect* dst)
