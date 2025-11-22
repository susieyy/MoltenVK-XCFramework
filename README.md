# MoltenVK-XCFramework

Binary distribution of MoltenVK as a Swift Package using XCFramework.

## Overview

This package provides the MoltenVK implementation as a pre-built binary XCFramework for easy integration with Swift Package Manager. MoltenVK is a Vulkan Portability implementation that runs on Apple's Metal graphics framework.

## Features

- **MoltenVK v1.4.0** - Vulkan implementation for Apple platforms
- **Static Library** - Uses `.a` static libraries (not dynamic)
- **Universal Binary** - Supports both Intel (x86_64) and Apple Silicon (arm64)
- **Binary-Only Distribution** - Small repository size, framework hosted on GitHub Releases
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

Then add `MoltenVK` to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "MoltenVK", package: "MoltenVK-XCFramework")
    ]
)
```

### Xcode Project

1. In Xcode, go to `File` > `Add Package Dependencies...`
2. Enter the repository URL: `https://github.com/susieyy/MoltenVK-XCFramework.git`
3. Select the version you want to use
4. Add `MoltenVK` to your target

## Usage

This package provides the MoltenVK binary framework. You'll need to import it in your C/Objective-C code or use a bridging header for Swift:

```c
#import <MoltenVK/mvk_vulkan.h>
// or
#import <vulkan/vulkan.h>
```

For Swift projects with Vulkan C API wrappers, see [MoltenVK-SPM](https://github.com/susieyy/MoltenVK-SPM) which includes Swift helper types and concurrency wrappers.

## Package Structure

This is a **binary-only** package:
- Repository contains only `Package.swift` and documentation
- The MoltenVK.xcframework binary is hosted on GitHub Releases
- Downloads automatically during package resolution

## Version Information

- **MoltenVK Version**: v1.4.0
- **Type**: Static library (.a)
- **Architecture**: Universal (arm64 + x86_64)
- **Platform**: macOS 13.0+

See `.MoltenVK-version` for detailed version information.

## Platform Support

Currently supports:
- macOS (arm64 + x86_64 universal binary)

Future platform support may include:
- iOS (device and simulator)
- tvOS
- visionOS

## Related Packages

- **[MoltenVK-SPM](https://github.com/susieyy/MoltenVK-SPM)** - Full package with Vulkan headers + binary + Swift wrappers
- This package (MoltenVK-XCFramework) - Binary-only distribution

Use this package if you:
- Only need the MoltenVK binary framework
- Want a smaller, binary-only dependency
- Already have Vulkan headers from another source

Use MoltenVK-SPM if you:
- Need Vulkan C headers included
- Want Swift 6.2 concurrency wrappers (async/await, actors)
- Need comprehensive tests and examples

## License

This package is a binary distribution wrapper. MoltenVK itself is licensed under:

- **MoltenVK**: [Apache License 2.0](https://github.com/KhronosGroup/MoltenVK/blob/main/LICENSE)

## Resources

- [MoltenVK Official Repository](https://github.com/KhronosGroup/MoltenVK)
- [Vulkan Documentation](https://www.vulkan.org/)
- [MoltenVK Documentation](https://github.com/KhronosGroup/MoltenVK/tree/main/Docs)

## Acknowledgments

- The Khronos Group for developing and maintaining Vulkan
- The MoltenVK team for bringing Vulkan to Apple platforms
