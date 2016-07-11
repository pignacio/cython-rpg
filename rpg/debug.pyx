from .sdl cimport Texture, Surface
from .SDL2 cimport Uint32, SDL_MapRGB, SDL_BLENDMODE_BLEND


cdef DebugObjects _DEBUG_INSTANCE
cdef Texture _DEBUG_PIXEL = None


cpdef DebugObjects get_instance():
    global _DEBUG_INSTANCE
    return _DEBUG_INSTANCE


cpdef debug_rect(SDL_Rect rect, SDL_Color color):
    cdef Uint32 new_pixel
    cdef Uint32* pixels
    global _DEBUG_PIXEL
    if not _DEBUG_INSTANCE.renderer:
        return
    if _DEBUG_PIXEL is None:
        pixel = Surface.create(1, 1)
        new_pixel = SDL_MapRGB(pixel.ptr.format, 255, 255, 255)
        with pixel.lock():
            pixels = <Uint32*> pixel.ptr.pixels
            pixels[0] = new_pixel
        _DEBUG_PIXEL = _DEBUG_INSTANCE.renderer.texture_from_surface(pixel)
        _DEBUG_PIXEL.set_blend_mode(SDL_BLENDMODE_BLEND)

    _DEBUG_PIXEL.set_color_mod(color.r, color.g, color.b)
    _DEBUG_PIXEL.set_alpha_mod(color.a)
    _DEBUG_INSTANCE.renderer.copy(_DEBUG_PIXEL, NULL, &rect)
