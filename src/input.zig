const ButtonState = @import("input/button.zig").ButtonState;
const KeyboardState = @import("input/keyboard.zig").KeyboardState;
const MouseState = @import("input/mouse.zig").MouseState;

pub const InputState = struct {
    keyboard: KeyboardState,
    mouse: MouseState,

    pub fn create() InputState {
        return InputState{
            .keyboard = KeyboardState.create(),
            .mouse = MouseState.create(),
        };
    }
};
