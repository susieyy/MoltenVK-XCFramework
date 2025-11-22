// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MoltenVK-XCFramework",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "MoltenVK",
            targets: ["MoltenVK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "MoltenVK",
            url: "https://github.com/susieyy/MoltenVK-XCFramework/releases/download/v1.4.0/MoltenVK.xcframework.zip",
            checksum: "8a92d141a5533fbf1fd04812937020e36544c1fff90ae7aeeaaad41f478ac359"
        ),
    ]
)
