from rpg.SDL2 cimport (
    SDL_Texture,
    SDL_Rect,
)

cdef class Blitter:
    cdef void blit_rect_to(self, TextureRect rect, int x, int y):
        raise NotImplementedError()
    cdef void blit_rect_to_rect(self, TextureRect rect, const SDL_Rect* dest):
        raise NotImplementedError()
    cdef void blit_full(self, SDL_Texture* texture, const SDL_Rect* src, const SDL_Rect* dst):
        raise NotImplementedError()


cdef class BasicBlitter(Blitter):
    def __cinit__(self, Renderer renderer):
        self.renderer = renderer

    cdef void blit_full(self, SDL_Texture* texture, const SDL_Rect* src, const SDL_Rect* dst):
        self.renderer.copy_ptr(texture, src, dst)
