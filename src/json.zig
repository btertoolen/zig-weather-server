const std = @import("std");
const unicode = @import("std").unicode;
const CurrentWeather = @import("api.zig").CurrentWeather;
const WeatherSummary = @import("api.zig").WeatherSummary;

pub const FormatResponse = struct {
    pub fn CurrentWeatherJson(
        allocator: std.mem.Allocator,
        weather: CurrentWeather,
    ) ![]u8 {
        const summary = try SummaryToChar(weather.summary);
        const summary_str = summary[0..];
        const buf = try std.fmt.allocPrint(allocator, "{{ \"summary\": \"{s}\", \"rain_mm\": {d:.1}, \"temperature\": {d:.1} }}", .{ summary_str, weather.rain_mm, weather.temperature });
        std.debug.print("buf: {s}\n", .{summary_str});

        return buf;
    }

    fn SummaryToChar(summary: WeatherSummary) ![4]u8 {
        var character: [4]u8 = undefined;
        _ = switch (summary) {
            .Thunderstorm => try std.unicode.utf8Encode(0x26A1, character[0..]),
            .Drizzle => try std.unicode.utf8Encode(0x1F4A7, character[0..]),
            .Clouds => try std.unicode.utf8Encode(0x2601, character[0..]),
            .Rain => try std.unicode.utf8Encode(0x1F327, character[0..]),
            .Snow => try std.unicode.utf8Encode(0x2601, character[0..]),
            .Atmosphere => try std.unicode.utf8Encode(0x1F32B, character[0..]),
            .Clear => try std.unicode.utf8Encode(0x2600, character[0..]),
        };
        return character;
    }
};
