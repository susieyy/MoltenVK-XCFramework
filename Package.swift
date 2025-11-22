// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MoltenVK-XCFramework",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        // Vulkan C Headers only
        .library(
            name: "VulkanHeaders",
            targets: ["VulkanHeaders"]
        ),
        // MoltenVK binary only
        .library(
            name: "MoltenVK",
            targets: ["MoltenVK"]
        ),
        // Complete package: Headers + MoltenVK (recommended)
        .library(
            name: "MoltenVK-Complete",
            targets: ["VulkanHeaders", "MoltenVK"]
        ),
    ],
    targets: [
        // Vulkan C Headers
        .target(
            name: "VulkanHeaders",
            path: "Sources/VulkanHeaders",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include")
            ]
        ),

        // MoltenVK prebuilt XCFramework
        .binaryTarget(
            name: "MoltenVK",
            url: "https://github.com/susieyy/MoltenVK-XCFramework/releases/download/1.4.0/MoltenVK.xcframework.zip",
            checksum: "8a92d141a5533fbf1fd04812937020e36544c1fff90ae7aeeaaad41f478ac359"
        ),
    ]
)
