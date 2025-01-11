const std = @import("std");
const unicode = @import("std").unicode;
const CurrentWeather = @import("api.zig").CurrentWeather;
const WeatherSummary = @import("api.zig").WeatherSummary;

pub const FormatResponse = struct {
    pub fn CurrentWeatherJson(
        allocator: std.mem.Allocator,
        weather: CurrentWeather,
    ) ![]u8 {
        var buf: [250]u8 = undefined;
        var index: usize = 0;

        index += (try std.fmt.bufPrint(&buf, "{{ ", .{})).len;

        inline for (std.meta.fields(@TypeOf(weather))) |f| {
            const slice = buf[index..];
            switch (@TypeOf(@field(weather, f.name))) {
                f64 => index += (try std.fmt.bufPrint(slice, " \"{s}\": {d:.1},", .{ f.name, @field(weather, f.name) })).len,
                [4]u8 => index += (try std.fmt.bufPrint(slice, " \"{s}\": \"{s}\",", .{ f.name, @field(weather, f.name) })).len,
                [5]u8 => index += (try std.fmt.bufPrint(slice, "\"{s}\": \"{s}\",", .{ f.name, @field(weather, f.name) })).len,
                else => @panic("Add formatting to parse this type to json"),
            }
        }
        buf[index - 1] = ' ';
        // buf[index] = "}";
        return std.fmt.allocPrint(allocator, "{s} }}\n", .{buf[0 .. index - 1]});
    }
};

// var string = std.ArrayList(u8).init(allocator);
// try std.json.stringify(weather, .{}, string.writer());

// return string.toOwnedSlice();
