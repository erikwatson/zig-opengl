const gl = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GL/gl.h");
});
const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

fn initialiseGlad() !void {
    const result = gl.gladLoadGLLoader(@ptrCast(&sdl.SDL_GL_GetProcAddress));
    if (result == gl.GL_FALSE) {
        std.debug.print("Failed to initialize GLAD\n", .{});
        return error.InitialiseGLADFailed;
    }
}

pub fn initialise(window: ?*sdl.SDL_Window, context: sdl.SDL_GLContext, width: c_int, height: c_int) !void {
    try initialiseGlad();
    gl.glViewport(0, 0, width, height);
    gl.glEnable(gl.GL_DEPTH_TEST);
    gl.glDepthFunc(gl.GL_LESS);

    const make_current_result = sdl.SDL_GL_MakeCurrent(window.?, context.?);
    if (!make_current_result) {
        std.debug.print("Failed to make OpenGL context current\n", .{});
        return error.GLContextDestroyFailed;
    }
}
