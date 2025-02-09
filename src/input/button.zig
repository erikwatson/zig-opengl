pub const ButtonState = struct {
    pressed: bool,
    released: bool,
    justPressed: bool,
    justReleased: bool,

    pub fn create() ButtonState {
        return ButtonState{
            .pressed = false,
            .released = false,
            .justPressed = false,
            .justReleased = false,
        };
    }
};
