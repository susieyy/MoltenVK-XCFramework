# MoltenVK-XCFramework

Binary distribution of MoltenVK as a Swift Package using XCFramework.

> **⚠️ IMPORTANT**: This is an **unofficial** binary distribution package. This is NOT the official MoltenVK repository.
> For the official MoltenVK project, visit: [KhronosGroup/MoltenVK](https://github.com/KhronosGroup/MoltenVK)

## Overview

This package provides the MoltenVK implementation as a pre-built binary XCFramework along with Vulkan C headers for easy integration with Swift Package Manager. MoltenVK is a Vulkan Portability implementation that runs on Apple's Metal graphics framework.

**This is an unofficial community package** created for convenient SPM distribution. All MoltenVK binaries are sourced from the official [KhronosGroup/MoltenVK releases](https://github.com/KhronosGroup/MoltenVK/releases).

## Features

- **MoltenVK v1.4.0** - Vulkan implementation for Apple platforms
- **Vulkan Headers SDK 1.4.328.1** - Complete Vulkan C API headers (included in repository)
- **Three Products** - VulkanHeaders, MoltenVK, or MoltenVK-Complete
- **Static Library** - Uses `.a` static libraries (not dynamic)
- **Universal Binary** - Supports both Intel (x86_64) and Apple Silicon (arm64)
- **Binary Distribution** - XCFramework hosted on GitHub Releases (no Git LFS)
- **Swift Package Manager** - Easy integration with SPM projects

## Requirements

- macOS 13.0+
- Xcode 16.4+ (Swift 6.2+)
- Swift 6.2+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/susieyy/MoltenVK-XCFramework.git", from: "1.4.0")
]
```

Then add to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        // Option 1: Headers + MoltenVK (recommended)
        .product(name: "MoltenVK-Complete", package: "MoltenVK-XCFramework")

        // Option 2: Just headers
        // .product(name: "VulkanHeaders", package: "MoltenVK-XCFramework")

        // Option 3: Just MoltenVK binary
        // .product(name: "MoltenVK", package: "MoltenVK-XCFramework")
    ]
)
```

### Xcode Project

1. In Xcode, go to `File` > `Add Package Dependencies...`
2. Enter the repository URL: `https://github.com/susieyy/MoltenVK-XCFramework.git`
3. Select the version you want to use
4. Add `MoltenVK` to your target

## Usage

### In C/Objective-C

```c
#import <vulkan/vulkan.h>

// Use Vulkan C API
VkInstance instance;
VkInstanceCreateInfo createInfo = {
    .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
    // ...
};
vkCreateInstance(&createInfo, NULL, &instance);
```

### In Swift (with Bridging Header)

Create a bridging header `YourProject-Bridging-Header.h`:

```c
#import <vulkan/vulkan.h>
```

Then use in Swift:

```swift
var instance: VkInstance?
var createInfo = VkInstanceCreateInfo()
createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
vkCreateInstance(&createInfo, nil, &instance)
```

For Swift projects with high-level wrappers (async/await, actors, noncopyable types), see [MoltenVK-SPM](https://github.com/susieyy/MoltenVK-SPM) which includes Swift 6.2 concurrency features.

## Package Structure

```
MoltenVK-XCFramework/
├── Package.swift              # SPM manifest with three products
├── Sources/
│   └── VulkanHeaders/         # Vulkan C headers (in repository)
│       └── include/
│           ├── vulkan/        # Vulkan SDK 1.4.328.1 headers
│           └── vk_video/      # Video codec headers
└── MoltenVK.xcframework       # Binary (15MB, on GitHub Releases)
```

This package provides three products:
- **VulkanHeaders**: Vulkan C API headers only (in repository, ~500KB)
- **MoltenVK**: MoltenVK binary framework only (hosted on GitHub Releases, ~15MB)
- **MoltenVK-Complete**: Both headers and binary (recommended)

The MoltenVK.xcframework binary is hosted on GitHub Releases to keep the repository lightweight and fast to clone.

## Version Information

### Current Release: 1.4.0

- **MoltenVK Version**: v1.4.0 (binary on GitHub Releases)
- **Vulkan Headers Version**: SDK 1.4.328.1 (included in repository)
- **Type**: Static library (.a)
- **Architecture**: Universal (arm64 + x86_64)
- **Platforms**: iOS 16.0+, macOS 13.0+
- **Distribution Method**: Binary on GitHub Releases, headers in repository

See `.MoltenVK-version` for detailed version metadata and upstream release information.

## Platform Support

Currently supports:
- macOS (arm64 + x86_64 universal binary)
- iOS Device (arm64)
- iOS Simulator (arm64 + x86_64)

Future platform support may include:
- tvOS (device and simulator)
- visionOS
- Mac Catalyst

## Package Products

This package provides three products:

### 1. MoltenVK-Complete (Recommended)
Includes both Vulkan headers and MoltenVK binary.

```swift
.product(name: "MoltenVK-Complete", package: "MoltenVK-XCFramework")
```

### 2. VulkanHeaders
Vulkan C headers only, if you want to provide your own Vulkan implementation.

```swift
.product(name: "VulkanHeaders", package: "MoltenVK-XCFramework")
```

### 3. MoltenVK
MoltenVK binary only, if you already have headers from another source.

```swift
.product(name: "MoltenVK", package: "MoltenVK-XCFramework")
```

## Updating MoltenVK

To update to a newer version of MoltenVK:

1. See [UPDATING.md](UPDATING.md) for detailed step-by-step instructions
2. The process involves downloading new MoltenVK releases, updating headers, and creating a new GitHub release
3. Both the binary (MoltenVK.xcframework) and headers (VulkanHeaders) should be updated together

For maintainers: UPDATING.md contains complete workflows for updating both components.

## Related Packages

- **[MoltenVK-SPM](https://github.com/susieyy/MoltenVK-SPM)** - Includes Swift 6.2 wrappers with async/await, actors, and noncopyable types

Use this package (MoltenVK-XCFramework) if you:
- Want to use Vulkan C API directly
- Need a lightweight dependency with just headers + binary
- Prefer the binary hosted on GitHub Releases

Use MoltenVK-SPM if you:
- Want Swift 6.2 concurrency wrappers (async/await, actors)
- Need noncopyable types for automatic resource management
- Want comprehensive tests and examples

## License

**DISCLAIMER**: This is an **unofficial** binary distribution package. This repository only provides packaging and distribution infrastructure. All MoltenVK binaries and headers are from the official upstream project.

MoltenVK itself is licensed under:

- **MoltenVK**: [Apache License 2.0](https://github.com/KhronosGroup/MoltenVK/blob/main/LICENSE)

This packaging repository is provided as-is for community convenience. For official support, issues, and contributions related to MoltenVK functionality, please use the [official MoltenVK repository](https://github.com/KhronosGroup/MoltenVK).

## Resources

- [MoltenVK Official Repository](https://github.com/KhronosGroup/MoltenVK)
- [Vulkan Documentation](https://www.vulkan.org/)
- [MoltenVK Documentation](https://github.com/KhronosGroup/MoltenVK/tree/main/Docs)

## Acknowledgments

- The Khronos Group for developing and maintaining Vulkan
- The MoltenVK team for bringing Vulkan to Apple platforms
