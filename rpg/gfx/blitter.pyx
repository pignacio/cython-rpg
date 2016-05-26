from rpg.SDL2 cimport (
    SDL_Texture,
    SDL_Rect,
)


cdef class Blitter:
    cdef void blit_full(self, SDL_Texture* texture, const SDL_Rect* src, const SDL_Rect* dst):
        self.renderer.copy_ptr(texture, src, dst)
