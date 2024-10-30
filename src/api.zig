const std = @import("std");
const print = std.debug.print;

const WeatherResponse = @import("struct.zig").WeatherResponse;
const WeatherData = @import("struct.zig").WeatherData;
const MainWeather = @import("struct.zig").MainWeather;
const WeatherCondition = @import("struct.zig").WeatherCondition;
const Clouds = @import("struct.zig").Clouds;
const Wind = @import("struct.zig").Wind;
const Sys = @import("struct.zig").Sys;

pub const GetWeather = struct {
    const api_url = "http://api.openweathermap.org/data/2.5/forecast?lat=51.4902&lon=5.5118&appid=6f4bf0b49ce6498772f0b2c5fa8f46a7&units=metric";
    fn fetchData(allocator: std.mem.Allocator) ![]u8 {
        const uri = try std.Uri.parse(api_url);
        var client = std.http.Client{ .allocator = allocator };
        defer client.deinit();

        const server_header_buffer: []u8 = try allocator.alloc(u8, 1024 * 8);
        var req = try client.open(.GET, uri, .{ .server_header_buffer = server_header_buffer });
        defer req.deinit();

        try req.send();
        try req.finish();
        try req.wait();

        std.debug.print("Response status: {d}", .{req.response.status});
        return req.reader().readAllAlloc(allocator, 1e5);
    }

    fn getUpcomingRain(data: []u8) !f32 {
        _ = data;
    }

    pub fn Get() !WeatherTimeslot {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        const data = try fetchData(allocator);
        _ = data;
        return WeatherTimeslot{ .rain_mm = 10.0, .time = 0 };
    }
};

pub const WeatherTimeslot = struct { rain_mm: f32, time: u64 };
