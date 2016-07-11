from libc.stdio cimport printf

from .SDL2 cimport (
    SDL_BlendMode,
    SDL_Color,
    SDL_ConvertSurface,
    SDL_CreateRenderer,
    SDL_CreateTextureFromSurface,
    SDL_CreateWindow,
    SDL_DestroyRenderer,
    SDL_DestroyTexture,
    SDL_DestroyWindow,
    SDL_FreeSurface,
    SDL_GetError,
    SDL_GetKeyboardState,
    SDL_GetWindowSurface,
    SDL_INIT_EVERYTHING,
    SDL_Init,
    SDL_LockSurface,
    SDL_MUSTLOCK,
    SDL_PixelFormat,
    SDL_Quit,
    SDL_Rect,
    SDL_RenderClear,
    SDL_RenderCopy,
    SDL_RenderFillRect,
    SDL_RenderPresent,
    SDL_SetRenderDrawColor,
    SDL_SetTextureBlendMode,
    SDL_Surface,
    SDL_UnlockSurface,
    SDL_Window,
    Uint32,
    Uint8,
)
from .SDL2_image cimport (
    IMG_INIT_JPG,
    IMG_INIT_PNG,
    IMG_Init,
    IMG_Load,
    IMG_Quit,
)
from .SDL2_ttf cimport (
    TTF_CloseFont,
    TTF_Init,
    TTF_OpenFont,
    TTF_Quit,
    TTF_RenderText_Solid,
)
from .logutils cimport log_info, log_sdl_err, log_sdl_warn


cdef class SDL:
    def __cinit__(self):
        self.sdl_inited = False
        self.sdl_image_inited = False
        self.sdl_ttf_inited = False

        log_info("Initing SDL")
        if SDL_Init(SDL_INIT_EVERYTHING) < 0:
            log_sdl_err("Could not init SDL")
            return
        else:
            self.sdl_inited = True

        log_info("Initing SDL_image")
        cdef int img_flags = IMG_INIT_JPG | IMG_INIT_PNG
        if (IMG_Init(img_flags) & img_flags) != img_flags:
            log_sdl_err("Could not init SDL_image")
            return
        else:
            self.sdl_image_inited = True

        log_info("Initing SDL_ttf")
        if TTF_Init() < 0:
            log_sdl_err("Could not init SDL_ttf")
        else:
            self.sdl_ttf_inited = True

    def __dealloc__(self):
        log_info("Cleaning SDL")
        log_info("Last SDL error: '%s'", SDL_GetError())
        if self.sdl_ttf_inited:
            log_info("Quitting SDL_ttf")
            TTF_Quit()

        if self.sdl_image_inited:
            log_info("Quitting SDL_image")
            IMG_Quit()

        if self.sdl_inited:
            log_info("Quitting SDL")
            SDL_Quit()


cdef class Window:
    def __dealloc__(self):
        log_info("Freeing Window[%p]", self.ptr)
        if self.ptr:
            SDL_DestroyWindow(self.ptr)
            self.ptr = NULL

    def __nonzero__(self):
        return self.ptr != NULL

    @staticmethod
    cdef Window create(const char* title, int x, int y, int w, int h, Uint32 flags):
        log_info("Creating Window '%s' (%d,%d,%d,%d)[%d]", title, x, y, w, h, flags)
        cdef SDL_Window* cWindow = SDL_CreateWindow(title, x, y, w, h, flags)
        window = Window()
        window.ptr = cWindow
        if not cWindow:
            log_sdl_err("Could not create window.")
        else:
            log_info("Created Window[%p]", cWindow)
        return window


cdef class Renderer:
    def __dealloc__(self):
        log_info("Destroying Renderer[%p]", self.ptr)
        if self.ptr:
            SDL_DestroyRenderer(self.ptr)
            self.ptr = NULL

    def __nonzero__(self):
        return self.ptr != NULL

    cdef int clear(self):
        return SDL_RenderClear(self.ptr)

    cdef void present(self):
        SDL_RenderPresent(self.ptr)

    cdef int set_draw_color(self, Uint8 r, Uint8 g, Uint8 b, Uint8 a):
        return SDL_SetRenderDrawColor(self.ptr, r, g, b, a)

    cdef int fill_rect(self, const SDL_Rect* rect):
        return SDL_RenderFillRect(self.ptr, rect)

    cdef int copy_ptr(self, SDL_Texture* texture, const SDL_Rect* src, const SDL_Rect* dest):
        return SDL_RenderCopy(self.ptr, texture, src, dest)

    cdef Texture texture_from_surface_ptr(self, SDL_Surface* surface):
        cdef SDL_Texture* texture = SDL_CreateTextureFromSurface(self.ptr, surface)
        if not texture:
            log_sdl_err("Could not create texture from Surface[%p]", surface)
            return None
        else:
            return Texture.wrap(texture, surface.w, surface.h)

    @staticmethod
    cdef Renderer create(SDL_Window *window, Uint32 flags):
        assert window
        log_info("Creating Renderer from Window[%p]", window)
        cdef SDL_Renderer* ptr = SDL_CreateRenderer(window, -1, flags)
        if not ptr:
            log_sdl_err("Could not create renderer from Window[%p]", window)
            return None
        else:
            log_info("Created Renderer[%p]", ptr)
            res = Renderer()
            res.ptr = ptr
            return res


cdef class SurfaceLock:
    def __init__(self, Surface surface):
        self.surface = surface

    def __enter__(self):
        if SDL_MUSTLOCK(self.surface.ptr):
            SDL_LockSurface(self.surface.ptr)
        return self

    def __exit__(self, type, value, traceback):
        if SDL_MUSTLOCK(self.surface.ptr):
            SDL_UnlockSurface(self.surface.ptr)


cdef class Surface:
    def __dealloc__(self):
        log_info("Freeing Surface[%p]", self.ptr)
        if self.ptr:
            SDL_FreeSurface(self.ptr)
            self.ptr = <SDL_Surface*>NULL

    def __nonzero__(self):
        return self.ptr != NULL

    cdef Surface optimized_for(self, SDL_PixelFormat* format):
        log_info("Optimizing Surface[%p] for PixelFormat<%d>. "
                 "Current PixelFormat<%d>", self.ptr,
                 format.format, self.ptr.format.format)
        cdef SDL_Surface* optimized = SDL_ConvertSurface(self.ptr, format, 0)
        if not optimized:
            log_sdl_err("Failed to optimize Surface[%p]", self.ptr)
        log_info("Optimized Surface[%p] -> Surface[%p]", self.ptr, optimized)
        return Surface.wrap(optimized)

    cdef SurfaceLock lock(self):
        return SurfaceLock(self)

    @staticmethod
    cdef Surface wrap(SDL_Surface* ptr):
        log_info("Wrapping Surface[%p]", ptr)
        cdef Surface surface = Surface()
        surface.ptr = ptr
        return surface

    @staticmethod
    cdef Surface load(const char* path, SDL_PixelFormat* format=NULL):
        cdef SDL_Surface* surface = IMG_Load(path)
        cdef Surface res
        if not surface:
            log_sdl_err("Could not load image '%s'", path)
            return None
        res = Surface.wrap(surface)
        if format:
            res = res.optimized_for(format)
        return res


cdef class Texture:
    def __dealloc__(self):
        log_info("Destroying Texture[%p]", self.ptr)
        if self.ptr:
            SDL_DestroyTexture(self.ptr)
            self.ptr = NULL

    def __nonzero__(self):
        return self.ptr != NULL

    cdef int set_blend_mode(self, SDL_BlendMode mode):
        res = SDL_SetTextureBlendMode(self.ptr, mode)
        if res < 0:
            log_sdl_warn("Could not set blend mode for Texture[%p]", self.ptr)
        return res

    @staticmethod
    cdef Texture wrap(SDL_Texture* ptr, int width, int height):
        assert ptr
        assert width > 0
        assert height > 0
        log_info("Wrapping Texture[%p] (%dx%d)", ptr, width, height)
        texture = Texture()
        texture.ptr = ptr
        texture.width = width
        texture.height = height
        return texture


cdef class Font:
    def __dealloc__(self):
        log_info("Closing Font[%p]", self.ptr)
        TTF_CloseFont(self.ptr)
        self.ptr = NULL

    @staticmethod
    cdef Font wrap(TTF_Font* ptr, int size):
        assert ptr
        log_info("Wrapping Font[%p] (%d)", ptr, size)
        font = Font()
        font.ptr = ptr
        font.size = size
        return font

    @staticmethod
    cdef Font open(const char* path, int size):
        cdef TTF_Font* ptr = TTF_OpenFont(path, size)
        if not ptr:
            log_sdl_err("Could not load font '%s'", path)
            return None
        return Font.wrap(ptr, size)

    cdef Surface render_text_solid(self, const char* text, SDL_Color color):
        cdef SDL_Surface* ptr = TTF_RenderText_Solid(self.ptr, text, color)
        if not ptr:
            log_sdl_err("Font[%p]: Could not render '%s'", self.ptr, text)
            return None
        return Surface.wrap(ptr)


cdef class KeyboardState:
    def __cinit__(self):
        self.update()

    cdef void update(self):
        self.state = SDL_GetKeyboardState(NULL)
