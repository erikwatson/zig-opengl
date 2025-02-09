const ButtonState = @import("button.zig").ButtonState;

pub const KeyboardState = struct {
    up: ButtonState,
    down: ButtonState,
    left: ButtonState,
    right: ButtonState,
    space: ButtonState,
    enter: ButtonState,
    escape: ButtonState,

    pub fn create() KeyboardState {
        return KeyboardState{
            .up = ButtonState.create(),
            .down = ButtonState.create(),
            .left = ButtonState.create(),
            .right = ButtonState.create(),
            .space = ButtonState.create(),
            .enter = ButtonState.create(),
            .escape = ButtonState.create(),
        };
    }
};
