cdef extern from "logutils.h" nogil:
    void log_info(const char *template, ...)
    void log_sdl_err(const char *template, ...)

