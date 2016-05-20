from SDL2 cimport (
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
    SDL_MapRGB,
    SDL_PollEvent,
    SDL_QUIT,
    SDL_Quit,
    SDL_Surface,
    SDL_UpdateWindowSurface,
    SDL_WINDOWPOS_UNDEFINED,
    SDL_WINDOW_OPENGL,
    SDL_WINDOW_SHOWN,
    SDL_Window,
    Uint32,
)
from libc.stdio cimport printf

cdef class Window:
    cdef SDL_Window* ptr

    def __dealloc__(self):
        printf("Freeing Window[%p]\n", self.ptr)
        if self.ptr:
            SDL_DestroyWindow(self.ptr)
        self.ptr = <SDL_Window*>NULL


cdef Window create_window(SDL_Window* ptr):
    printf("Creating Window[%p]\n", ptr)
    window = Window()
    window.ptr = ptr
    return window

cdef inline int abs(int x):
    return x if x >=0 else -x

cpdef main():
    cdef SDL_Window *cWindow = NULL;
    cdef SDL_Surface *screen = NULL;
    cdef int quit = 0;
    cdef int r=0, g=0, b=0;
    cdef SDL_Event event;
    cdef Uint32 start;
    cdef Uint32 elapsed;
    cdef int frames = 0;
    cdef double fps;
    cdef Window window;
    if SDL_Init(SDL_INIT_EVERYTHING) < 0:
        printf("Error initing! '%s'\n", SDL_GetError())
    else:
        cWindow = SDL_CreateWindow("SDL Tutorial", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_SHOWN)
        if not cWindow:
            printf("Problems creating window: '%s'\n", SDL_GetError())
        else:
            window = create_window(cWindow)
            screen = SDL_GetWindowSurface(window.ptr)
            start = SDL_GetTicks()
            while not quit:
                while SDL_PollEvent(&event):
                    if event.type == SDL_QUIT:
                        quit = 1
                r = (r + 1) % 511
                g = (g + 3) % 511
                b = (b + 5) % 511

                SDL_FillRect(screen, NULL, SDL_MapRGB(screen.format, abs(r - 255), abs(g - 255), abs(b - 255)))
                SDL_UpdateWindowSurface(window.ptr)
                frames += 1
            elapsed = SDL_GetTicks() - start
            fps = <double>frames / <double> elapsed * 1000.
            printf("%d frames in %d ms. %.2f FPS\n", frames, elapsed, fps);
        SDL_Quit()
