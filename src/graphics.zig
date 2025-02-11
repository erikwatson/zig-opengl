const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});
const gl = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GL/gl.h");
});
const std = @import("std");

pub const Graphics = struct {
    window: *sdl.SDL_Window,
    gl_context: ?*sdl.struct_SDL_GLContextState,
    shader_program: u32,

    vertex_shader_source: []const u8 =
        \\ #version 410 core
        \\ layout (location = 0) in vec3 aPos;
        \\ layout (location = 1) in vec3 aColor;
        \\ 
        \\ out vec3 vertexColor; // Pass color to fragment shader
        \\ 
        \\ void main() {
        \\     gl_Position = vec4(aPos, 1.0);
        \\     vertexColor = aColor;
        \\ }
    ,

    fragment_shader_source: []const u8 =
        \\ #version 410 core
        \\ in vec3 vertexColor;
        \\ out vec4 FragColor;
        \\ 
        \\ void main() {
        \\     FragColor = vec4(vertexColor, 1.0); // Use the interpolated color
        \\ }
    ,

    // Initialize OpenGL context and shaders
    pub fn init(self: *Graphics) void {
        var vertex_shader: u32 = undefined;
        var fragment_shader: u32 = undefined;

        if (self.compileShader(
            self.vertex_shader_source,
            gl.GL_VERTEX_SHADER,
        )) |shader| {
            vertex_shader = shader;
        } else |err| {
            std.debug.print("Error compiling vertex shader: {}\n", .{err});
            return;
        }

        if (self.compileShader(
            self.fragment_shader_source,
            gl.GL_FRAGMENT_SHADER,
        )) |shader| {
            fragment_shader = shader;
        } else |err| {
            std.debug.print("Error compiling fragment shader: {}\n", .{err});
            return;
        }

        if (self.createShaderProgram(
            vertex_shader,
            fragment_shader,
        )) |program| {
            self.shader_program = program;
        } else |err| {
            std.debug.print("Error creating shader program: {}\n", .{err});
            return;
        }
    }

    // Shader compilation
    fn compileShader(self: *Graphics, shader_source: []const u8, shader_type: u32) !u32 {
        _ = self; // autofix
        const shader = gl.glCreateShader(shader_type);
        gl.glShaderSource(shader, 1, &shader_source.ptr, null);
        gl.glCompileShader(shader);

        var success: i32 = 0;
        gl.glGetShaderiv(shader, gl.GL_COMPILE_STATUS, &success);
        if (success == 0) {
            var info_log: [512]u8 = undefined;
            gl.glGetShaderInfoLog(shader, 512, null, &info_log[0]);

            // Fix print statement: use {s} to print the array as a string
            std.debug.print("Error compiling shader: {s}\n", .{info_log});
            return error.CreateShaderFailed;
        }

        return shader;
    }

    fn createShaderProgram(self: *Graphics, vertex_shader: u32, fragment_shader: u32) !c_uint {
        _ = self; // autofix
        const shader_program = gl.glCreateProgram();
        gl.glAttachShader(shader_program, vertex_shader);
        gl.glAttachShader(shader_program, fragment_shader);
        gl.glLinkProgram(shader_program);

        var success: i32 = 0;
        gl.glGetProgramiv(shader_program, gl.GL_LINK_STATUS, &success);

        if (success == 0) {
            return error.CreateShaderProgramFailed;
        }

        return shader_program;
    }

    pub fn drawTriangle(self: *Graphics) void {
        gl.glDisable(gl.GL_DEPTH_TEST);

        // Define triangle vertices
        var vertices: [18]f32 = .{
            //  Position        |    Color
            -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, // Bottom-left (Red)
            0.5, -0.5, 0.0, 0.0, 1.0, 0.0, // Bottom-right (Green)
            0.0, 0.5, 0.0, 0.0, 0.0, 1.0, // Top (Blue)
        };

        // Create and bind VAO
        var vertex_array: u32 = undefined;
        gl.glGenVertexArrays(1, &vertex_array);
        gl.glBindVertexArray(vertex_array);

        // Create and bind VBO
        var vertex_buffer: u32 = undefined;
        gl.glGenBuffers(1, &vertex_buffer);
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vertex_buffer);
        gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf([18]f32), &vertices, gl.GL_STATIC_DRAW);

        // Enable position attribute (location = 0)
        gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 6 * @sizeOf(f32), null);
        gl.glEnableVertexAttribArray(0);

        // Enable color attribute (location = 1)
        gl.glVertexAttribPointer(1, 3, gl.GL_FLOAT, gl.GL_FALSE, 6 * @sizeOf(f32), @ptrFromInt(3 * @sizeOf(f32)));
        gl.glEnableVertexAttribArray(1);

        // Use the shader and draw
        gl.glUseProgram(self.shader_program);
        gl.glBindVertexArray(vertex_array);
        gl.glDrawArrays(gl.GL_TRIANGLES, 0, 3);
        gl.glBindVertexArray(0);
    }
};
