const Input = @import("input.zig");
const InputState = Input.InputState;
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});
const SDL3 = @import("sdl3.zig");
const Window = SDL3.Window;
const std = @import("std");

pub const Game = struct {
    pub fn processInputs(self: *Game) InputState {
        _ = self; // autofix
        var inputs = InputState.create();
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != false) {
            if (event.type == sdl.SDL_EVENT_KEY_DOWN) {
                switch (event.key.key) { // Use `event.key.key` to access SDL_Keycode
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

    pub fn update(self: *Game, inputs: InputState, dt: f32) void {
        _ = self; // autofix
        _ = dt; // autofix
        _ = inputs; // autofix
        // ...
    }

    pub fn render(self: *Game) void {
        _ = self; // autofix

        // clear the window
    }

    pub fn start(self: *Game, title: [*c]const u8, width: c_int, height: c_int) void {
        var window = Window.create(title, width, height) catch |err| {
            std.debug.print("Error creating window: {}\n", .{err});
            return;
        };
        defer window.destroy();

        var running = true;
        while (running) {
            const inputs = self.processInputs();

            if (inputs.keyboard.escape.pressed) {
                running = false;
            }

            window.clear() catch |err| {
                std.debug.print("Error clearing window: {}\n", .{err});
                return;
            };

            window.present();
        }
    }
};
