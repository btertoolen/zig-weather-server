const std = @import("std");
const WeatherTimeslot = @import("api.zig").WeatherTimeslot;
const GetWeather = @import("api.zig").GetWeather;

pub fn main() !void {
    const weather = try GetWeather.Get();
    std.debug.print("Weather: {d:.1}", .{weather.rain_mm});
}
