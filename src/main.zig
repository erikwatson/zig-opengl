const Game = @import("game.zig").Game;

pub fn main() !void {
    var game = Game{};
    game.start("My amazing game", 1920, 1080);

    return;
}
