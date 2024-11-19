const std = @import("std");
const http = std.http;
const net = std.net;
const WeatherTimeslot = @import("api.zig").WeatherTimeslot;
const GetWeather = @import("api.zig").GetWeather;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const weather = try GetWeather.GetNow();
    std.debug.print("Weather: {s}\n", .{@tagName(weather.summary)});

    const http_read_buffer = try allocator.alloc(u8, 1e4);
    // const server = http.Server.init(.{ .address = try net.Address.resolveIp("127.0.0.1", 1234), .stream = .{} }, http_read_buffer);
    var server_address = try net.Address.resolveIp("127.0.0.1", 1234);
    var server = try server_address.listen(.{});
    const connection = try server.accept();
    var http_server = http.Server.init(connection, http_read_buffer);
    std.debug.print("Server state: {s}", .{@tagName(http_server.state)});
    _ = try http_server.receiveHead();
}
