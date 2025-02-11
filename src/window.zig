const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

const SDL = @import("sdl3.zig").SDL;

const gl = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GL/gl.h");
});

const std = @import("std");
const OpenGl = @import("opengl.zig");

const Error = error{
    SdlInitFailed,
    SDLGLSetAttributeFailed,
    SDLGLSetMakeCurrentFailed,
    GLSwapWindowFailed,
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
        // Initialize SDL
        try SDL.init(sdl.SDL_INIT_VIDEO);

        // Set OpenGL version to 4.1 core
        try SDL.GL.setAttribute(sdl.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
        try SDL.GL.setAttribute(sdl.SDL_GL_CONTEXT_MINOR_VERSION, 1);
        try SDL.GL.setAttribute(sdl.SDL_GL_CONTEXT_PROFILE_MASK, sdl.SDL_GL_CONTEXT_PROFILE_CORE);

        // Create the window
        var window: Window = undefined;
        window.sdl_window = try SDL.createWindow(
            title,
            width,
            height,
            sdl.SDL_EVENT_WINDOW_SHOWN | sdl.SDL_WINDOW_OPENGL,
        );

        // Create and initialise the OpenGl context
        window.sdl_context = try SDL.GL.createContext(window.sdl_window);
        try SDL.GL.makeCurrent(window.sdl_window.?, window.sdl_context);
        try SDL.GL.setSwapInterval(1); // enable vsync
        try OpenGl.initialise(width, height);

        return window;
    }

    pub fn destroy(self: *Window) void {
        if (self.sdl_window) |window| {
            SDL.destroyWindow(window);
        }
        if (self.sdl_renderer) |renderer| {
            SDL.destroyRenderer(renderer);
        }
        if (self.sdl_context) |context| {
            SDL.GL.destroyContext(context) catch |err| {
                std.debug.print("Failed to destroy OpenGL context: {}\n", .{err});
            };
        }
    }

    pub fn clear(self: *Window) !void {
        if (self.sdl_context) |context| {
            _ = context; // autofix
            gl.glClearColor(0.2, 0.3, 0.3, 1.0);
            gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);
        }
    }

    pub fn present(self: *Window) !void {
        if (self.sdl_window) |window| {
            SDL.GL.swapWindow(window) catch |err| {
                std.debug.print("Failed to swap window: {}\n", .{err});
                return error.GLSwapWindowFailed;
            };
        } else {
            return error.GLSwapWindowFailed;
        }
    }
};
