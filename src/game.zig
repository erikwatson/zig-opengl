const Input = @import("input.zig");
const InputState = Input.InputState;
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});
const Window = @import("window.zig").Window;
const std = @import("std");
const Graphics = @import("graphics.zig").Graphics;

pub const Game = struct {
    title: [*c]const u8 = null,
    width: c_int = 0,
    height: c_int = 0,
    update: ?*const fn (InputState) void = null,
    render: ?*const fn (*Graphics) void = null,

    pub fn setUpdate(self: *Game, callback: *const fn (InputState) void) void {
        self.update = callback;
    }

    pub fn setRender(self: *Game, callback: *const fn (*Graphics) void) void {
        self.render = callback;
    }

    pub fn start(self: *Game) void {
        var window = Window.create(
            self.title,
            self.width,
            self.height,
        ) catch |err| {
            std.debug.print("Error creating window: {}\n", .{err});
            return;
        };
        defer window.destroy();

        if (window.sdl_context == null) {
            std.debug.print("Failed to create OpenGL context\n", .{});
            return;
        }

        var graphics = Graphics{
            .window = window.sdl_window.?,
            .gl_context = window.sdl_context,
            .shader_program = 0,
        };
        graphics.init();

        var running = true;
        while (running) {
            // process inputs
            const inputs = self.processInputs();

            if (inputs.keyboard.escape.pressed) {
                running = false;
            }

            if (self.update) |callback| {
                callback(inputs);
            }

            // update game state
            window.clear() catch |err| {
                std.debug.print("Error clearing window: {}\n", .{err});
                return;
            };

            // render game state
            if (self.render) |callback| {
                callback(&graphics);
            }

            window.present() catch |err| {
                std.debug.print("Error presenting window: {}\n", .{err});
                return;
            };
        }
    }

    fn processInputs(self: *Game) InputState {
        _ = self; // autofix
        var inputs = InputState.create();
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != false) {
            if (event.type == sdl.SDL_EVENT_KEY_DOWN) {
                switch (event.key.key) {
                    sdl.SDLK_UP => inputs.keyboard.up.pressed = true,
                    sdl.SDLK_DOWN => inputs.keyboard.down.pressed = true,
                    sdl.SDLK_LEFT => inputs.keyboard.left.pressed = true,
                    sdl.SDLK_RIGHT => inputs.keyboard.right.pressed = true,
                    sdl.SDLK_SPACE => inputs.keyboard.space.pressed = true,
                    sdl.SDLK_RETURN => inputs.keyboard.enter.pressed = true,
                    sdl.SDLK_ESCAPE => inputs.keyboard.escape.pressed = true,
                    else => {},
                }
            }
        }

        return inputs;
    }
};
