const std = @import("std");
const print = std.debug.print;

const WeatherResponse = @import("struct.zig").WeatherResponse;
const WeatherData = @import("struct.zig").WeatherData;
const MainWeather = @import("struct.zig").MainWeather;
const WeatherCondition = @import("struct.zig").WeatherCondition;
const Clouds = @import("struct.zig").Clouds;
const Wind = @import("struct.zig").Wind;
const Rain = @import("struct.zig").Rain;
const Sys = @import("struct.zig").Sys;
const CityCoord = @import("struct.zig").CityCoord;
const City = @import("struct.zig").City;
const ListItem = @import("struct.zig").ListItem;
const ApiResponse = @import("struct.zig").ApiResponse;

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

        return req.reader().readAllAlloc(allocator, 1e5);
    }

    fn getUpcomingRain(data: []u8) !f32 {
        _ = data;
    }

    pub fn Get() !WeatherTimeslot {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        // const allocator = arena.allocator();

        // const data = try fetchData(allocator);
        return WeatherTimeslot{ .summary = .Clear, .rain_mm = 10.0, .time = 0 };
    }

    fn replace_invalid_json_keys_in_place(data: []u8) void {
        const search = '3';
        const search_2 = 'h';
        const replacement_char = 't';
        const search_len = 2;

        var i: usize = 0;
        while (i + search_len <= data.len) {
            if (data[i] == search and data[i + 1] == search_2) {
                // Replace "3h" with "th" in place
                data[i] = replacement_char;
                i += search_len; // Skip over the replaced substring
            } else {
                i += 1; // Move to the next byte
            }
        }
    }

    fn getWeatherSummary(id: u32) !WeatherSummary {
        return switch (id) {
            200...299 => .Thunderstorm,
            300...399 => .Drizzle,
            400...499 => .Rain,
            600...699 => .Snow,
            700...799 => .Atmosphere,
            800 => .Clear,
            801...900 => .Clouds,
            else => error.UnknownId,
        };
    }

    pub fn GetNow() !CurrentWeather {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        const data = try fetchData(allocator);
        replace_invalid_json_keys_in_place(data);

        _ = try std.json.validate(allocator, data);
        const json = try std.json.parseFromSlice(ApiResponse, allocator, data, .{});

        const weather_summary = json.value.list[0].weather.?[0];
        const rain_mm = if (json.value.list[0].rain) |rain|
            rain.th
        else
            0.0;

        const temperature = json.value.list[0].main.temp;
        return CurrentWeather{ .summary = try getWeatherSummary(weather_summary.id), .rain_mm = rain_mm, .temperature = temperature };
    }
};

pub const WeatherSummary = enum(u8) {
    Thunderstorm = 0,
    Drizzle = 1,
    Rain = 2,
    Snow = 3,
    Atmosphere = 4,
    Clear = 8,
    Clouds = 9,
};

pub const CurrentWeather = struct { summary: WeatherSummary, rain_mm: f64, temperature: f64 };
pub const WeatherTimeslot = struct { summary: WeatherSummary, rain_mm: f32, time: u64 };
