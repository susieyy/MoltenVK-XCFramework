// Dummy source file to satisfy Xcode's requirement for .o file generation
// VulkanHeaders is a headers-only package, but Xcode requires at least one source file
//
// This file is intentionally minimal and serves only to allow Xcode to compile
// VulkanHeaders as a target and produce VulkanHeaders.o during the build process.
//
// Swift Package Manager (SPM) correctly handles headers-only targets without this file,
// but Xcode's build system requires at least one compilable source file.

void vulkan_headers_dummy(void) {
    // This function intentionally does nothing
    // It exists only to provide a compilable symbol for the linker
}
