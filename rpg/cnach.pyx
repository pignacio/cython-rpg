from .SDL2 cimport (
    SDLK_ESCAPE,
    SDLK_q,
    SDL_BlitSurface,
    SDL_CreateWindow,
    SDL_Delay,
    SDL_DestroyWindow,
    SDL_Event,
    SDL_FillRect,
    SDL_GLContext,
    SDL_GL_CONTEXT_MAJOR_VERSION,
    SDL_GL_CONTEXT_MINOR_VERSION,
    SDL_GL_CreateContext,
    SDL_GL_SetAttribute,
    SDL_GL_SetSwapInterval,
    SDL_GL_SwapWindow,
    SDL_GetError,
    SDL_GetTicks,
    SDL_GetWindowSurface,
    SDL_INIT_EVERYTHING,
    SDL_INIT_VIDEO,
    SDL_Init,
    SDL_KEYDOWN,
    SDL_MapRGB,
    SDL_PollEvent,
    SDL_QUIT,
    SDL_Quit,
    SDL_Rect,
    SDL_RENDERER_ACCELERATED,
    SDL_RENDERER_PRESENTVSYNC,
    SDL_Surface,
    SDL_Texture,
    SDL_UpdateWindowSurface,
    SDL_WINDOWPOS_UNDEFINED,
    SDL_WINDOW_OPENGL,
    SDL_WINDOW_SHOWN,
    SDL_Window,
    Uint32,
)
from .sdl cimport (
    Renderer,
    Renderer_create,
    SDL,
    Surface,
    Surface_load,
    Window,
    Window_create,
)
from .logutils cimport log_info
from libc.stdio cimport printf


cdef inline int abs(int x):
    return x if x >=0 else -x


cdef struct TextureRect:
    SDL_Texture* texture
    SDL_Rect rect


# cdef TextureRect TextureRect_full(SDL_Texture* texture):
#     return TextureRect(texture, True, SDL_Rect(0,0,0,0))
#
#
# cdef TextureRect TextureRect_partial(SDL_Texture* texture, SDL_Rect rect):
#     return TextureRect(texture, False, rect)


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

    cdef inline void blit_full(self, SDL_Texture* texture, const SDL_Rect* src, const SDL_Rect* dst):
        self.renderer.copy_ptr(texture, src, dst)


cpdef main():
    cdef SDL_Event event
    cdef Uint32 start
    cdef Uint32 elapsed
    cdef double fps
    cdef int frames = 0
    cdef SDL_Rect srcrect, dstrect;

    sdl = SDL()

    window = Window_create(
        "SDL Tutorial",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        800,
        600,
        SDL_WINDOW_SHOWN)
    renderer = Renderer_create(window.ptr, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)
    blitter = Blitter()
    blitter.renderer = renderer
    start = SDL_GetTicks()
    image = Surface_load('character.png')
    texture = renderer.texture_from_surface(image)

    srcrect.x = dstrect.x = 0
    srcrect.y = dstrect.y = 0
    srcrect.w = dstrect.w = 32
    srcrect.h = dstrect.h = 32

    quit = False
    while not quit:
        while SDL_PollEvent(&event):
            if event.type == SDL_QUIT:
                quit = True
            elif event.type == SDL_KEYDOWN:
                key = event.key.keysym.sym
                if key == SDLK_q or key == SDLK_ESCAPE:
                    quit = True
        renderer.set_draw_color(0, 0, 0, 255)
        renderer.clear()
        srcrect.x = dstrect.x = (frames) % (texture.width - 32)
        srcrect.y = dstrect.y = (frames * 2) % (texture.height - 32)
        blitter.blit_rect_to(TextureRect(texture.ptr, srcrect), dstrect.x, dstrect.y)
        renderer.present()
        # SDL_BlitSurface(image.ptr, NULL, window.surface, NULL)
        # SDL_UpdateWindowSurface(window.ptr)
        frames += 1
    elapsed = SDL_GetTicks() - start
    fps = <double>frames / <double> elapsed * 1000.
    log_info("%d frames in %d ms. %.2f FPS", frames, elapsed, fps);
