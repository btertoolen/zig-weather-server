const std = @import("std");

pub const WeatherResponse = struct {
    cod: []const u8,
    message: i32,
    cnt: i32,
    list: []WeatherData,
};

pub const WeatherData = struct {
    dt: i64,
    main: MainWeather,
    weather: []WeatherCondition,
    clouds: Clouds,
    wind: Wind,
    visibility: i32,
    pop: f32,
    sys: Sys,
    dt_txt: []const u8,
};

pub const MainWeather = struct {
    temp: f32,
    feels_like: f32,
    temp_min: f32,
    temp_max: f32,
    pressure: i32,
    sea_level: i32,
    grnd_level: i32,
    humidity: i32,
    temp_kf: f32,
};

pub const WeatherCondition = struct {
    id: i32,
    main: []const u8,
    description: []const u8,
    icon: []const u8,
};

pub const Clouds = struct {
    all: i32,
};

pub const Wind = struct {
    speed: f32,
    deg: i32,
    gust: f32,
};

pub const Sys = struct {
    pod: []const u8,
};
