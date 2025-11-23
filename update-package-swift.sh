#!/bin/bash
set -e

# Package.swift Update Script
# Updates Package.swift with new release URL and checksum

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Usage: $0 <version> <checksum>${NC}"
    echo "Example: $0 1.4.0 abc123..."
    echo ""
    echo "The checksum should be in checksum.txt after running add-ios-support.sh"
    exit 1
fi

VERSION="$1"
CHECKSUM="$2"
URL="https://github.com/susieyy/MoltenVK-XCFramework/releases/download/${VERSION}/MoltenVK.xcframework.zip"

echo -e "${BLUE}=== Updating Package.swift ===${NC}"
echo "Version: $VERSION"
echo "URL: $URL"
echo "Checksum: $CHECKSUM"
echo ""

# Backup current Package.swift
cp Package.swift Package.swift.backup
echo -e "${GREEN}✓ Backed up Package.swift${NC}"

# Create new Package.swift
cat > Package.swift << EOF
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
            url: "$URL",
            checksum: "$CHECKSUM"
        ),
    ]
)
EOF

echo -e "${GREEN}✓ Package.swift updated${NC}"
echo "Backup saved to: Package.swift.backup"
echo ""

# Validate the syntax
echo -e "${BLUE}Validating Package.swift syntax...${NC}"
if swift package dump-package > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Package.swift syntax is valid${NC}"
else
    echo -e "${RED}✗ Package.swift has syntax errors${NC}"
    echo "Restoring backup..."
    mv Package.swift.backup Package.swift
    exit 1
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Verify the package resolves:"
echo -e "   ${BLUE}rm -rf .build Package.resolved && swift package resolve${NC}"
echo ""
echo "2. Commit the changes:"
echo -e "   ${BLUE}git add Package.swift${NC}"
echo -e "   ${BLUE}git commit -m 'Update Package.swift for version ${VERSION} with iOS support'${NC}"
