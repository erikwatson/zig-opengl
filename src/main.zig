const Game = @import("game.zig").Game;
const InputState = @import("input.zig").InputState;
const Graphics = @import("graphics.zig").Graphics;

fn update(inputs: InputState) void {
    _ = inputs; // autofix
}

fn render(gfx: *Graphics) void {
    gfx.drawTriangle();
}

pub fn main() !void {
    var game = Game{
        .title = "My amazing game",
        .width = 1920,
        .height = 1080,
    };
    game.setUpdate(update);
    game.setRender(render);
    game.start();
    return;
}
