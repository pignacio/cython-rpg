from SDL2 cimport (
    SDL_BlendMode,
    SDL_PixelFormat,
    SDL_Rect,
    SDL_Renderer,
    SDL_Surface,
    SDL_Texture,
    SDL_Window,
    Uint8,
    Uint32,
)

cdef class SDL:
    cdef bint sdl_inited
    cdef bint sdl_image_inited


cdef class Window:
    cdef SDL_Window* ptr
cdef Window Window_create(const char* title, int x, int y, int w, int h, Uint32 flags)


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
cdef Renderer Renderer_create(SDL_Window* window, Uint32 flags)


cdef class Surface:
    cdef SDL_Surface* ptr
    cdef Surface optimized_for(self, SDL_PixelFormat* format)
cdef Surface Surface_wrap(SDL_Surface* ptr)
cdef Surface Surface_load(const char* path, SDL_PixelFormat* format=*)


cdef class Texture:
    cdef SDL_Texture* ptr
    cdef int width
    cdef int height

    cdef int set_blend_mode(self, SDL_BlendMode mode)
cdef Texture Texture_wrap(SDL_Texture* ptr, int width, int height)
