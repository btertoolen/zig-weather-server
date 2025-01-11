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

    var weather = try GetWeather.GetNow();
    std.debug.print("Weather: {s}\n", .{weather.summary});
    var last_fetch = std.time.timestamp();
    const timeout = 60;

    const http_read_buffer = try allocator.alloc(u8, 1e4);
    var server_address = try net.Address.resolveIp("127.0.0.1", 1234);
    var server = try server_address.listen(.{});
    defer server.deinit();
    while (true) {
        const connection = try server.accept();
        defer connection.stream.close();
        var http_server = http.Server.init(connection, http_read_buffer);
        var request = http_server.receiveHead() catch continue;
        const reader = try request.reader();
        const buffer = try reader.readAllAlloc(allocator, 200);
        defer allocator.free(buffer); // ignore the contents?
        if (std.time.timestamp() - last_fetch > timeout) {
            weather = try GetWeather.GetNow();
            last_fetch = std.time.timestamp();
        }
        const response = try FormatResponse.CurrentWeatherJson(allocator, weather);
        _ = request.respond(response, .{}) catch unreachable;
    }
}
