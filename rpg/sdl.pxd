from SDL2 cimport (
    SDL_BlendMode,
    SDL_Color,
    SDL_PixelFormat,
    SDL_Rect,
    SDL_Renderer,
    SDL_Surface,
    SDL_Texture,
    SDL_Window,
    SDL_Scancode,
    Uint8,
    Uint32,
)
from SDL2_ttf cimport (
    TTF_Font,
)

cdef class SDL:
    cdef bint sdl_inited
    cdef bint sdl_image_inited
    cdef bint sdl_ttf_inited


cdef class Window:
    cdef SDL_Window* ptr

    @staticmethod
    cdef Window create(const char* title, int x, int y, int w, int h, Uint32 flags)


cdef class Renderer:
    cdef SDL_Renderer* ptr

    cdef int clear(self)
    cdef void present(self)
    cdef int fill_rect(self, const SDL_Rect* rect)
    cdef int set_draw_color(self, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
    cdef int copy_ptr(self, SDL_Texture* texture, const SDL_Rect* src, const SDL_Rect* dest)
    cdef inline int copy(self, Texture texture, const SDL_Rect* src, const SDL_Rect* dest):
        return self.copy_ptr(texture.ptr, src, dest)

    cdef Texture texture_from_surface_ptr(self, SDL_Surface* surface)
    cdef inline Texture texture_from_surface(self, Surface surface):
        return self.texture_from_surface_ptr(surface.ptr)
    @staticmethod
    cdef Renderer create(SDL_Window* window, Uint32 flags)


cdef class SurfaceLock:
    cdef Surface surface


cdef class Surface:
    cdef SDL_Surface* ptr
    cdef Surface optimized_for(self, SDL_PixelFormat* format)
    cdef SurfaceLock lock(self)

    @staticmethod
    cdef Surface wrap(SDL_Surface* ptr)
    @staticmethod
    cdef Surface load(const char* path, SDL_PixelFormat* format=*)
    @staticmethod
    cdef Surface create(int width, int height, int depth=*)


cdef class Texture:
    cdef SDL_Texture* ptr
    cdef int width
    cdef int height

    cdef int set_blend_mode(self, SDL_BlendMode mode)
    cdef int set_color_mod(self, Uint8 r, Uint8 g, Uint8 b)
    cdef int set_alpha_mod(self, Uint8 a)
    @staticmethod
    cdef Texture wrap(SDL_Texture* ptr, int width, int height)


cdef class Font:
    cdef TTF_Font* ptr
    cdef int size

    @staticmethod
    cdef Font wrap(TTF_Font* ptr, int size)
    @staticmethod
    cdef Font open(const char* path, int size)

    cdef Surface render_text_solid(self, const char* text, SDL_Color color)


cdef class KeyboardState:
    cdef Uint8* state

    cdef void update(self)

    cdef inline bint isOn(self, SDL_Scancode key):
        return self.state[<int>key]
