const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

const gl = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GL/gl.h");
});

const std = @import("std");

const Error = error{
    WindowInitFailed,
    RendererInitFailed,
    PresentFailed,
    GLContextDestroyFailed,
    InitialiseGLADFailed,
};

pub fn initialiseGlad() !void {
    const result = gl.gladLoadGLLoader(@ptrCast(&sdl.SDL_GL_GetProcAddress));
    if (result == gl.GL_FALSE) {
        std.debug.print("Failed to initialize GLAD\n", .{});
        return error.InitialiseGLADFailed;
    }
}

pub const Window = struct {
    sdl_window: ?*sdl.SDL_Window,
    sdl_renderer: ?*sdl.SDL_Renderer,
    sdl_context: ?sdl.SDL_GLContext,

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
        window.sdl_context = sdl.SDL_GL_CreateContext(window.sdl_window);

        if (window.sdl_context == null) {
            std.debug.print("Error creating OpenGL context\n", .{});
            return error.GLContextDestroyFailed;
        } else {
            std.debug.print("OpenGL context created\n", .{});
        }

        // Initialize GLAD
        initialiseGlad() catch |err| {
            // output the error to the console
            std.debug.print("Handled error: {}\n", .{err});
        };

        gl.glViewport(0, 0, width, height);
        gl.glEnable(gl.GL_DEPTH_TEST);
        gl.glDepthFunc(gl.GL_LESS);

        // Make the OpenGL context current
        const make_current_result = sdl.SDL_GL_MakeCurrent(window.sdl_window.?, window.sdl_context.?);
        if (!make_current_result) {
            std.debug.print("Failed to make OpenGL context current\n", .{});
            return error.GLContextDestroyFailed;
        }

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
                // output the error to the console
                std.debug.print("Handled error: {}\n", .{err});
            };
        }
    }

    pub fn clear(self: *Window) !void {
        if (self.sdl_context) |context| {
            _ = context; // autofix
            // Now that we know context is not null, we can safely use it
            gl.glClearColor(0.2, 0.3, 0.3, 1.0); // Set a teal-ish background color
            gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);
        } else {
            return error.GLContextDestroyFailed; // Handle the error if the context is null
        }
    }

    pub fn present(self: *Window) void {
        if (self.sdl_window) |window| {
            if (!sdl.SDL_GL_SwapWindow(window)) {
                std.debug.print("Failed to swap window\n", .{});
            }
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
