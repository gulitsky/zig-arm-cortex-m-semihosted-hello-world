const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("hello_world", "./src/main.zig");
    exe.setBuildMode(mode);
    // Pick ONE of these compilations targets.
    // exe.setTarget(builtin.Arch.armv6m, builtin.Os.freestanding, builtin.Environ.eabi);    // Bare Cortex-M0, M0+, M1
    exe.setTarget(builtin.Arch.armv7m, builtin.Os.freestanding, builtin.Environ.eabi);    // Bare Cortex-M3
    // exe.setTarget(builtin.Arch.armv7em, builtin.Os.freestanding, builtin.Environ.eabi);   // Bare Cortex-M4, M7
    // exe.setTarget(builtin.Arch.armv7em, builtin.Os.freestanding, builtin.Environ.eabihf); // Bare Cortex-M4F, M7F, FPU, hardfloat
    b.default_step.dependOn(&exe.step);

    const qemu = b.step("qemu", "Execute program on QEMU");
    const run_qemu = b.addCommand(".", b.env_map, [][]const u8 {
        "qemu-system-arm",
        "-cpu",
        // At the moment QEMU does not support Cortex-M0, M0+ and M1 MCUs.
        "cortex-m3",
        // "cortex-m4",
        // At the moment QEMU does not support Cortex-M4F and M7F MCUs.
        "-machine",
        "lm3s6965evb",
        "-nographic",
        "-semihosting-config",
        "enable=on,target=native",
        "-kernel",
        "zig-cache/hello_world"
    });
    qemu.dependOn(&run_qemu.step);
    run_qemu.step.dependOn(&exe.step);
}