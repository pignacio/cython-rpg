from .sdl cimport Renderer, Texture, Surface
from .SDL2 cimport SDL_Rect, SDL_Color


cdef class DebugObjects:
    cdef:
        Renderer renderer


cpdef DebugObjects get_instance()
cpdef debug_rect(SDL_Rect rect, SDL_Color color)
