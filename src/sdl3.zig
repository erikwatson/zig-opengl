const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

const gl = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GL/gl.h");
});

const std = @import("std");
const OpenGl = @import("opengl.zig");

const Error = error{
    WindowInitFailed,
    RendererInitFailed,
    PresentFailed,
    GLContextDestroyFailed,
    InitialiseGLADFailed,
};

pub const Window = struct {
    sdl_window: ?*sdl.SDL_Window,
    sdl_renderer: ?*sdl.SDL_Renderer,
    sdl_context: sdl.SDL_GLContext,

    pub fn create(
        title: [*c]const u8,
        width: c_int,
        height: c_int,
    ) !Window {
        var window: Window = undefined;
        window.sdl_window = try createWindow(
            title,
            width,
            height,
            sdl.SDL_EVENT_WINDOW_SHOWN | sdl.SDL_WINDOW_OPENGL,
        );
        window.sdl_context = try createContext(window.sdl_window);

        try OpenGl.initialise(
            window.sdl_window,
            window.sdl_context,
            width,
            height,
        );

        return window;
    }

    pub fn destroy(self: *Window) void {
        if (self.sdl_window) |window| {
            destroyWindow(window);
        }
        if (self.sdl_renderer) |renderer| {
            destroyRenderer(renderer);
        }
        if (self.sdl_context) |context| {
            glDestroyContext(context) catch |err| {
                std.debug.print("Handled error: {}\n", .{err});
            };
        }
    }

    pub fn clear(self: *Window) !void {
        if (self.sdl_context) |context| {
            _ = context; // autofix
            gl.glClearColor(0.2, 0.3, 0.3, 1.0);
            gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);
        } else {
            return error.GLContextDestroyFailed;
        }
    }

    pub fn present(self: *Window) !void {
        if (self.sdl_window) |window| {
            if (!sdl.SDL_GL_SwapWindow(window)) {
                return error.PresentFailed;
            }
        } else {
            return error.PresentFailed;
        }
    }
};

pub fn logMessage(message: [*c]const u8) void {
    sdl.SDL_LogMessage(sdl.SDL_LOG_CATEGORY_APPLICATION, sdl.SDL_LOG_PRIORITY_INFO, message);
}

fn createWindow(title: [*c]const u8, w: c_int, h: c_int, flags: sdl.SDL_WindowFlags) !*sdl.SDL_Window {
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

pub fn createContext(window: ?*sdl.SDL_Window) !sdl.SDL_GLContext {
    const context = sdl.SDL_GL_CreateContext(window);
    if (context == null) {
        return error.GLContextDestroyFailed;
    } else {
        return context;
    }
}

pub fn renderClear(renderer: *sdl.SDL_Renderer) !void {
    if (!sdl.SDL_RenderClear(renderer)) {
        return error.ClearFailed;
    }
}

pub fn renderPresent(renderer: *sdl.SDL_Renderer) !void {
    if (!sdl.SDL_RenderPresent(renderer)) {
        return error.PresentFailed;
    }
}

pub fn renderDrawColor(renderer: *sdl.SDL_Renderer, r: u8, g: u8, b: u8, a: u8) !void {
    if (!sdl.SDL_SetRenderDrawColor(renderer, r, g, b, a)) {
        return error.ClearFailed;
    }
}

pub fn destroyWindow(window: *sdl.SDL_Window) void {
    sdl.SDL_DestroyWindow(window);
}

pub fn destroyRenderer(renderer: *sdl.SDL_Renderer) void {
    sdl.SDL_DestroyRenderer(renderer);
}

pub fn glDestroyContext(context: sdl.SDL_GLContext) !void {
    if (!sdl.SDL_GL_DestroyContext(context)) {
        return error.GLContextDestroyFailed;
    }
}
