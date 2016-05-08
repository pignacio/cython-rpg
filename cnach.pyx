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
from cOpenGL cimport (
    GL_COLOR_BUFFER_BIT,
    GL_MODELVIEW,
    GL_NO_ERROR,
    GL_PROJECTION,
    GL_QUADS,
    GLenum,
    glBegin,
    glClear,
    glClearColor,
    glEnd,
    glGetError,
    glLoadIdentity,
    glMatrixMode,
    glVertex2f,
    gluErrorString,
    glutSwapBuffers,
    glutInit,
    glutInitContextVersion,
)

cdef class Window:
    cdef SDL_Window* ptr

    def __dealloc__(self):
        printf("Freeing Window[%p]", self.ptr)
        if self.ptr:
            SDL_DestroyWindow(self.ptr)
        self.ptr = <SDL_Window*>NULL


cdef Window create_window(SDL_Window* ptr):
    printf("Creating Window[%p]", ptr)
    window = Window()
    window.ptr = ptr
    return window

cdef inline int abs(int x):
    return x if x >=0 else -x

cpdef main2():
    cdef SDL_Window *window = NULL;
    cdef SDL_Surface *screen = NULL;
    cdef int quit = 0;
    cdef int r=0, g=0, b=0;
    cdef SDL_Event event;
    cdef Uint32 start;
    cdef Uint32 elapsed;
    cdef int frames = 0;
    cdef double fps;
    if SDL_Init(SDL_INIT_EVERYTHING) < 0:
        printf("Error initing! '%s'", SDL_GetError())
    else:
        window = SDL_CreateWindow("SDL Tutorial", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 800, 600, SDL_WINDOW_SHOWN)
        if not window:
            printf("Problems creating window: '%s'", SDL_GetError())
        else:
            screen = SDL_GetWindowSurface(window)
            start = SDL_GetTicks()
            while not quit:
                while SDL_PollEvent(&event):
                    if event.type == SDL_QUIT:
                        quit = 1
                r = (r + 1) % 511
                g = (g + 3) % 511
                b = (b + 5) % 511

                SDL_FillRect(screen, NULL, SDL_MapRGB(screen.format, abs(r - 255), abs(g - 255), abs(b - 255)))
                SDL_UpdateWindowSurface(window)
                frames += 1
            elapsed = SDL_GetTicks() - start
            fps = <double>frames / <double> elapsed * 1000.
            printf("%d frames in %d ms. %.2f FPS", frames, elapsed, fps);
        SDL_DestroyWindow(window)
        SDL_Quit()

cdef extern from "string.h":
    char* strstr(const char *haystack, const char *needle)

cpdef test():
    pos = strstr(needle="akv", haystack="lanlsfnklanlfnasklnfakv")
    printf("%s", "null" if pos == NULL else "not null")

cdef SDL_Window *gWindow
cdef SDL_GLContext gContext;

cdef int init():
    global gWindow
    global gContext
    if SDL_Init(SDL_INIT_VIDEO) < 0:
        printf("SDL could not initialize: '%s'\n", SDL_GetError())
        return -1

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2)
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1)
    gWindow = SDL_CreateWindow(
        "SDL Tutorial",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        800,
        600,
        SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL,
    )
    if not gWindow:
        printf("Window could not be created: SDL Error: '%s'\n", SDL_GetError())
        return -2

    gContext = SDL_GL_CreateContext(gWindow)
    if not gContext:
        printf("OpenGL context could not be created! SDL Error: '%s'\n", SDL_GetError())
        return -3

    if SDL_GL_SetSwapInterval(1) < 0:
        printf("Warning: Unable to set VSync! SDL Error: '%s'\n", SDL_GetError())

    if initGL() < 0:
        printf("Unable to init OpenGL!\n")
        return -4
    return 0

cdef int initGL():
    cdef GLenum error = GL_NO_ERROR;
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    error = glGetError();
    if error != GL_NO_ERROR:
        printf("Error initializing OpenGL! '%s'\n", gluErrorString(error))
        return -1

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()
    error = glGetError();
    if error != GL_NO_ERROR:
        printf("Error initializing OpenGL! '%s'\n", gluErrorString(error))
        return -2

    glClearColor(0, 0, 0, 1)
    error = glGetError();
    if error != GL_NO_ERROR:
        printf("Error initializing OpenGL! '%s'\n", gluErrorString(error))
        return -3
    return 0

cdef void update():
    pass

cdef void render():
    glClear(GL_COLOR_BUFFER_BIT)
    glBegin(GL_QUADS)
    glVertex2f(-.5, -.5)
    glVertex2f(.5, -.5)
    glVertex2f(.5, .5)
    glVertex2f(-.5, .5)
    glEnd()


cpdef main():
    global gWindow
    cdef int quit = 0;
    cdef SDL_Event event;
    cdef Uint32 start;
    cdef Uint32 elapsed;
    cdef int frames = 0;
    cdef double fps;

    if init() < 0:
        printf("Could not initialized!")
        return -1
    start = SDL_GetTicks()
    while not quit:
        while SDL_PollEvent(&event):
            if event.type == SDL_QUIT:
                quit = 1

        render()
        SDL_GL_SwapWindow(gWindow)
        frames += 1
    elapsed = SDL_GetTicks() - start
    fps = <double>frames / <double> elapsed * 1000.
    printf("%d frames in %d ms. %.2f FPS\n", frames, elapsed, fps);
    if gWindow:
        SDL_DestroyWindow(gWindow)
    SDL_Quit()
