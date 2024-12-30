const std = @import("std");
const http = std.http;
const net = std.net;
const WeatherTimeslot = @import("api.zig").WeatherTimeslot;
const GetWeather = @import("api.zig").GetWeather;
const FormatResponse = @import("json.zig").FormatResponse;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const weather = try GetWeather.GetNow();
    std.debug.print("Weather: {s}\n", .{@tagName(weather.summary)});

    const http_read_buffer = try allocator.alloc(u8, 1e4);
    var server_address = try net.Address.resolveIp("127.0.0.1", 1234);
    var server = try server_address.listen(.{});
    while (true) {
        const connection = try server.accept();
        defer connection.stream.close();
        var http_server = http.Server.init(connection, http_read_buffer);
        var request = http_server.receiveHead() catch continue;
        const reader = try request.reader();
        const buffer = try reader.readAllAlloc(allocator, 200);
        allocator.free(buffer); // ignore the contents?
        _ = try request.respond(try FormatResponse.CurrentWeatherJson(allocator, weather), .{});
    }
}
