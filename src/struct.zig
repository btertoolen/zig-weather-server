const std = @import("std");

pub const WeatherCondition = struct {
    id: u32,
    main: []const u8,
    description: []const u8,
    icon: []const u8,
};

pub const MainWeather = struct {
    temp: f64,
    feels_like: f64,
    temp_min: ?f64 = 0.0, // Make this optional
    temp_max: ?f64 = 0.0, // Make this optional
    pressure: f64,
    sea_level: f64,
    grnd_level: f64,
    humidity: u32,
    temp_kf: f64,
};

pub const Clouds = struct {
    all: u32,
};

pub const Wind = struct {
    speed: f64,
    deg: f64,
    gust: f64,
};

pub const Rain = struct {
    th: f64 = 0.0, // Make this optional
};

pub const Snow = struct {
    th: ?f64 = 0.0, // Make this optional
};

pub const Sys = struct {
    pod: ?[]const u8 = undefined, // Make this optional
};

pub const CityCoord = struct {
    lat: ?f64 = 0.0, // Make this optional
    lon: ?f64 = 0.0, // Make this optional
};

pub const City = struct {
    id: u32,
    name: []const u8,
    coord: CityCoord,
    country: []const u8,
    population: u32,
    timezone: u32,
    sunrise: u32,
    sunset: u32,
};

pub const ListItem = struct {
    dt: u32,
    main: MainWeather,
    weather: ?[]WeatherCondition = undefined, // Make this optional (it could be empty)
    clouds: ?Clouds = undefined, // Make this optional
    wind: ?Wind = undefined, // Make this optional
    visibility: ?u32 = 0, // Make this optional
    pop: ?f64 = 0.0, // Make this optional
    rain: ?Rain = undefined, // Make this optional
    snow: ?Snow = undefined, // Make this optional
    sys: Sys,
    dt_txt: []const u8,
};

pub const ApiResponse = struct {
    cod: []const u8,
    message: u32,
    cnt: u32,
    list: []ListItem,
    city: City,
};
