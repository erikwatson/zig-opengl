const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

const gl = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GL/gl.h");
});

const std = @import("std");
const OpenGl = @import("opengl.zig");

const Error = error{ SDL_WindowInitFailed, SDL_RendererInitFailed, SDL_PresentFailed, SDL_GL_ContextDestroyFailed, SDL_GL_SetAttributeFailed, SDL_GL_MakeCurrentFailed, SDL_Gl_SwapWindowFailed, SDL_GL_SetSwapIntervalFailed };

const SDL_GL = struct {
    pub fn setAttribute(attribute: sdl.SDL_GLAttr, value: c_int) !void {
        if (!sdl.SDL_GL_SetAttribute(attribute, value)) {
            return error.SDL_GL_SetAttributeFailed;
        }
    }

    pub fn makeCurrent(window: *sdl.SDL_Window, context: sdl.SDL_GLContext) !void {
        if (!sdl.SDL_GL_MakeCurrent(window, context)) {
            return error.SDL_GL_MakeCurrentFailed;
        }
    }

    pub fn swapWindow(window: *sdl.SDL_Window) !void {
        if (!sdl.SDL_GL_SwapWindow(window)) {
            return error.SDL_GL_SwapWindowFailed;
        }
    }

    pub fn setSwapInterval(interval: c_int) !void {
        if (!sdl.SDL_GL_SetSwapInterval(interval)) {
            // get the error and print it
            const err = sdl.SDL_GetError();
            std.debug.print("SDL_GL_SetSwapInterval failed: {s}\n", .{err});

            return error.SetSwapIntervalFailed;
        }
    }

    pub fn createContext(window: ?*sdl.SDL_Window) !sdl.SDL_GLContext {
        const context = sdl.SDL_GL_CreateContext(window);
        if (context == null) {
            return error.GLCreateContextFailed;
        } else {
            return context;
        }
    }

    pub fn destroyContext(context: sdl.SDL_GLContext) !void {
        if (context == null) {
            return error.GLContextDestroyFailed; // Context is invalid
        }

        if (!sdl.SDL_GL_DestroyContext(context)) {
            return error.GLContextDestroyFailed;
        }
    }
};

pub const SDL = struct {
    pub const GL = SDL_GL;

    pub fn init(flags: sdl.SDL_InitFlags) !void {
        if (!sdl.SDL_Init(flags)) {
            return error.SdlInitFailed;
        }
    }

    pub fn createWindow(title: [*c]const u8, w: c_int, h: c_int, flags: sdl.SDL_WindowFlags) !*sdl.SDL_Window {
        if (sdl.SDL_CreateWindow(title, w, h, flags)) |window| {
            return window;
        } else {
            return error.WindowInitFailed;
        }
    }

    pub fn createRenderer(window: *sdl.SDL_Window) !*sdl.SDL_Renderer {
        if (sdl.SDL_CreateRenderer(window, null)) |renderer| {
            return renderer;
        } else {
            return error.RendererInitFailed;
        }
    }

    pub fn renderClear(renderer: *sdl.SDL_Renderer) !void {
        if (!sdl.SDL_RenderClear(renderer)) {
            return error.RenderClearFailed;
        }
    }

    pub fn renderPresent(renderer: *sdl.SDL_Renderer) !void {
        if (!sdl.SDL_RenderPresent(renderer)) {
            return error.RenderPresentFailed;
        }
    }

    pub fn renderDrawColor(renderer: *sdl.SDL_Renderer, r: u8, g: u8, b: u8, a: u8) !void {
        if (!sdl.SDL_SetRenderDrawColor(renderer, r, g, b, a)) {
            return error.RenderDrawColourFailed;
        }
    }

    pub fn destroyWindow(window: *sdl.SDL_Window) void {
        sdl.SDL_DestroyWindow(window);
    }

    pub fn destroyRenderer(renderer: *sdl.SDL_Renderer) void {
        sdl.SDL_DestroyRenderer(renderer);
    }
};
