#!/bin/bash
set -e

# MoltenVK Multi-Platform XCFramework Build Script
# This script builds a multi-platform XCFramework with macOS and iOS (device + simulator) support

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MOLTENVK_VERSION="${MOLTENVK_VERSION:-v1.4.0}"
WORK_DIR="$(pwd)/build-xcframework"
REPO_ROOT="$(pwd)"

echo -e "${BLUE}=== MoltenVK Multi-Platform XCFramework Build ===${NC}"
echo "Version: $MOLTENVK_VERSION"
echo "Work directory: $WORK_DIR"
echo ""

# Step 1: Download MoltenVK-all archive
echo -e "${GREEN}Step 1: Downloading MoltenVK archive...${NC}"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

if [ ! -f "MoltenVK-all.tar" ]; then
    echo "Downloading MoltenVK-all archive (includes all platforms)..."
    curl -L "https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-all.tar" \
        -o MoltenVK-all.tar
else
    echo "MoltenVK-all archive already exists, skipping download"
fi

echo -e "${GREEN}✓ Download complete${NC}\n"

# Step 2: Extract archive
echo -e "${GREEN}Step 2: Extracting archive...${NC}"
mkdir -p all

echo "Extracting MoltenVK-all archive..."
tar -xf MoltenVK-all.tar -C all

echo -e "${GREEN}✓ Extraction complete${NC}\n"

# Step 3: Verify static framework exists
echo -e "${GREEN}Step 3: Verifying static framework...${NC}"

ALL_FRAMEWORK="all/MoltenVK/MoltenVK/static/MoltenVK.xcframework"

if [ ! -d "$ALL_FRAMEWORK" ]; then
    echo -e "${RED}Error: Static framework not found at $ALL_FRAMEWORK${NC}"
    exit 1
fi

# List available platforms in the framework
echo "Available platforms in MoltenVK.xcframework:"
ls -1 "$ALL_FRAMEWORK" | grep -v Info.plist || true

echo -e "${GREEN}✓ Frameworks verified${NC}\n"

# Step 4: Create multi-platform XCFramework
echo -e "${GREEN}Step 4: Creating multi-platform XCFramework...${NC}"

# Remove old combined framework if it exists
rm -rf MoltenVK.xcframework

# Build the xcodebuild command with selected platforms
XCODEBUILD_CMD="xcodebuild -create-xcframework"

# Add macOS (required)
if [ -d "$ALL_FRAMEWORK/macos-arm64_x86_64" ]; then
    XCODEBUILD_CMD="$XCODEBUILD_CMD -library $ALL_FRAMEWORK/macos-arm64_x86_64/libMoltenVK.a"
    echo "✓ Added macOS (arm64 + x86_64)"
fi

# Add iOS device (required)
if [ -d "$ALL_FRAMEWORK/ios-arm64" ]; then
    XCODEBUILD_CMD="$XCODEBUILD_CMD -library $ALL_FRAMEWORK/ios-arm64/libMoltenVK.a"
    echo "✓ Added iOS device (arm64)"
fi

# Add iOS simulator (required)
if [ -d "$ALL_FRAMEWORK/ios-arm64_x86_64-simulator" ]; then
    XCODEBUILD_CMD="$XCODEBUILD_CMD -library $ALL_FRAMEWORK/ios-arm64_x86_64-simulator/libMoltenVK.a"
    echo "✓ Added iOS simulator (arm64 + x86_64)"
fi

# Optionally add Mac Catalyst
if [ -d "$ALL_FRAMEWORK/ios-arm64_x86_64-maccatalyst" ]; then
    # XCODEBUILD_CMD="$XCODEBUILD_CMD -library $ALL_FRAMEWORK/ios-arm64_x86_64-maccatalyst/libMoltenVK.a"
    echo "  (Mac Catalyst available but not included)"
fi

# Optionally add tvOS
if [ -d "$ALL_FRAMEWORK/tvos-arm64_arm64e" ]; then
    # XCODEBUILD_CMD="$XCODEBUILD_CMD -library $ALL_FRAMEWORK/tvos-arm64_arm64e/libMoltenVK.a"
    echo "  (tvOS device available but not included)"
fi

if [ -d "$ALL_FRAMEWORK/tvos-arm64_x86_64-simulator" ]; then
    # XCODEBUILD_CMD="$XCODEBUILD_CMD -library $ALL_FRAMEWORK/tvos-arm64_x86_64-simulator/libMoltenVK.a"
    echo "  (tvOS simulator available but not included)"
fi

echo ""

# Add output path
XCODEBUILD_CMD="$XCODEBUILD_CMD -output MoltenVK.xcframework"

echo "Running: $XCODEBUILD_CMD"
eval $XCODEBUILD_CMD

echo -e "${GREEN}✓ Multi-platform XCFramework created${NC}\n"

# Verify the created framework
echo "Created XCFramework contains:"
cat MoltenVK.xcframework/Info.plist | grep -A 1 "LibraryIdentifier" | grep string || true
echo ""

# Step 5: Copy to repository root
echo -e "${GREEN}Step 5: Copying to repository...${NC}"
cd "$REPO_ROOT"

# Backup old framework
if [ -d "MoltenVK.xcframework" ]; then
    echo "Backing up old framework..."
    mv MoltenVK.xcframework MoltenVK.xcframework.backup
fi

# Copy new framework
echo "Copying new multi-platform framework..."
cp -R "$WORK_DIR/MoltenVK.xcframework" ./

echo -e "${GREEN}✓ Framework copied${NC}\n"

# Step 6: Create ZIP and calculate checksum
echo -e "${GREEN}Step 6: Creating ZIP and calculating checksum...${NC}"

# Remove old ZIP if exists
rm -f MoltenVK.xcframework.zip

# Create new ZIP
zip -r MoltenVK.xcframework.zip MoltenVK.xcframework

# Calculate checksum
CHECKSUM=$(swift package compute-checksum MoltenVK.xcframework.zip)
echo "Checksum: $CHECKSUM"
echo "$CHECKSUM" > checksum.txt

echo -e "${GREEN}✓ ZIP created and checksum calculated${NC}\n"

# Step 7: Update version file
echo -e "${GREEN}Step 7: Updating version file...${NC}"

cat > .MoltenVK-version << EOF
Version: ${MOLTENVK_VERSION}
Release Date: $(date +%Y-%m-%d)
Source: https://github.com/KhronosGroup/MoltenVK/releases/tag/${MOLTENVK_VERSION}
Download URL: https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-all.tar
Type: Static (.a)
Architecture: Universal (arm64 + x86_64)
Platforms: macOS, iOS (device + simulator)

Vulkan API Version: 1.4.323
Package Created: $(date +%Y-%m-%d)

Distribution: Binary-only (GitHub Releases)
Repository: https://github.com/susieyy/MoltenVK-XCFramework
EOF

echo -e "${GREEN}✓ Version file updated${NC}\n"

# Step 8: Display next steps
echo -e "${YELLOW}=== Next Steps ===${NC}\n"

SPM_VERSION="${MOLTENVK_VERSION#v}"

echo "1. Create a GitHub release:"
echo -e "${BLUE}   gh release create ${SPM_VERSION} MoltenVK.xcframework.zip \\
     --title \"MoltenVK ${SPM_VERSION} with iOS Support\" \\
     --notes \"Multi-platform binary including macOS and iOS (device + simulator)\"${NC}"
echo ""

echo "2. After creating the release, update Package.swift with:"
echo -e "${BLUE}   URL: https://github.com/susieyy/MoltenVK-XCFramework/releases/download/${SPM_VERSION}/MoltenVK.xcframework.zip${NC}"
echo -e "${BLUE}   Checksum: ${CHECKSUM}${NC}"
echo ""

echo "3. Update README.md to reflect iOS support in the Platform Support section"
echo ""

echo "4. Test the package:"
echo -e "${BLUE}   rm -rf .build Package.resolved
   swift package resolve${NC}"
echo ""

echo -e "${GREEN}=== Script Complete ===${NC}"
echo "Checksum saved to: checksum.txt"
echo "Work directory: $WORK_DIR"
echo "Framework backup: MoltenVK.xcframework.backup (if existed)"
