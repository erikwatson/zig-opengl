const ButtonState = @import("button.zig").ButtonState;
const Position = @import("position.zig").Position;

pub const MouseState = struct {
    position: Position,
    left: ButtonState,
    right: ButtonState,

    pub fn create() MouseState {
        return MouseState{
            .position = Position{
                .x = 0.0,
                .y = 0.0,
            },
            .left = ButtonState.create(),
            .right = ButtonState.create(),
        };
    }
};
