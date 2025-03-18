pub fn main() !void {
    const file = try std.fs.cwd().openFile("test.png", .{});
    defer file.close();
    const stat = try file.stat();
    const buf: []u8 = try file.readToEndAlloc(std.heap.smp_allocator, stat.size);
    var img_fmt: c_int = 0;
    var img_width: c_int = 0;
    var img_height: c_int = 0;
    const img_data = stb.stbi_load_from_memory(buf.ptr, @intCast(buf.len), &img_width, &img_height, &img_fmt, 0);
    _ = img_data;
    std.log.debug("image {any} {any} {any}", .{ img_width, img_height, img_fmt });
}

const std = @import("std");
//const stb = @import("stb");

const stb = @cImport({
    @cInclude("stb_image.h");
});
pub const std_options: std.Options = .{
    .log_level = .debug,
};
