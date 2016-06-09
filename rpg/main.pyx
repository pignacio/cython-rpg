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
    SDL_GetKeyboardState,
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
    SDL_RENDERER_ACCELERATED,
    SDL_RENDERER_PRESENTVSYNC,
    SDL_Rect,
    SDL_SCANCODE_DOWN,
    SDL_SCANCODE_LEFT,
    SDL_SCANCODE_RIGHT,
    SDL_SCANCODE_UP,
    SDL_Surface,
    SDL_Texture,
    SDL_UpdateWindowSurface,
    SDL_WINDOWPOS_UNDEFINED,
    SDL_WINDOW_OPENGL,
    SDL_WINDOW_SHOWN,
    SDL_Window,
    Uint8,
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
from rpg.gfx.blitter cimport BasicBlitter, TextureRect
from rpg.image.sprite_sheet cimport SpriteSheet
from rpg.map.map cimport Map, Tileset, Actor
from rpg.types cimport Point
from .logutils cimport log_info
from libc.stdio cimport printf

def main():
    # run()
    # return
    import cProfile
    cProfile.runctx("run()", globals(), locals(), sort='cumulative')

cpdef run():
    cdef SDL_Event event
    cdef Uint32 start
    cdef Uint32 elapsed
    cdef Uint32 last_tick
    cdef double fps
    cdef int frames = 0, last_frames = 0
    cdef SDL_Rect srcrect, dstrect
    cdef int tile_id = 0
    cdef int x, y
    cdef Uint8* keyboard_state

    sdl = SDL()

    window = Window_create(
        "SDL Tutorial",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        800,
        600,
        SDL_WINDOW_SHOWN)
    renderer = Renderer_create(window.ptr, SDL_RENDERER_ACCELERATED)
    blitter = BasicBlitter(renderer)
    start = last_tick = SDL_GetTicks()
    image = Surface_load('character.png')
    texture = renderer.texture_from_surface(image)
    sheet = SpriteSheet(texture, 32, 48)
    log_info("Sheet is %d x %d", sheet._width(), sheet._height())

    map_texture = renderer.texture_from_surface(Surface_load('tileset3.png'))
    tilesize = 32
    map_data = [[[x + y, 10 + x + y] for y in xrange(10)] for x in xrange(10)]
    tileset = Tileset(map_texture, tilesize)
    map = Map(tileset, 10, 10, 800, 600, map_data)
    map.main_actor = Actor(sheet.get_tile_by_id(0), Point(100, 100), SDL_Rect(-10, -10, 20, 20))

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

        keyboard_state = SDL_GetKeyboardState(NULL)
        if keyboard_state[<int>SDL_SCANCODE_UP]:
            map.main_actor.position.y -= 1
        if keyboard_state[<int>SDL_SCANCODE_DOWN]:
            map.main_actor.position.y += 1
        if keyboard_state[<int>SDL_SCANCODE_LEFT]:
            map.main_actor.position.x -= 1
        if keyboard_state[<int>SDL_SCANCODE_RIGHT]:
            map.main_actor.position.x += 1

        renderer.set_draw_color(0, 0, 0, 255)
        renderer.clear()
        srcrect.x = dstrect.x = (frames) % (texture.width - 32)
        srcrect.y = dstrect.y = (frames * 2) % (texture.height - 32)
        tile_id = ((SDL_GetTicks() - start) / 200) % 16
        # for x in xrange(5, 10):
        #     for y in xrange(5, 10):
        #         blitter.blit_rect_to(sheet.get_tile_by_id((tile_id + x + 10 * y) % 16), 32 * x, 48 * y)

        map.draw(blitter, 0, 0)
        renderer.present()
        # SDL_BlitSurface(image.ptr, NULL, window.surface, NULL)
        # SDL_UpdateWindowSurface(window.ptr)
        frames += 1
        if SDL_GetTicks() - last_tick > 1000:
            current = SDL_GetTicks()
            elapsed = current - last_tick
            fps = <double>(frames - last_frames) / <double> elapsed * 1000.
            log_info("%d frames in %d ms. %.2f FPS", frames - last_frames, elapsed, fps)
            last_tick = current
            last_frames = frames

    elapsed = SDL_GetTicks() - start
    fps = <double>frames / <double> elapsed * 1000.
    log_info("%d frames in %d ms. %.2f FPS", frames, elapsed, fps);
