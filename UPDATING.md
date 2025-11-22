# Updating MoltenVK.xcframework

This guide provides step-by-step instructions for updating the MoltenVK.xcframework to a newer version in this binary distribution package.

## Prerequisites

### Required Tools

- **curl or wget**: For downloading releases
- **tar**: For extracting archives (pre-installed on macOS)
- **zip**: For creating the xcframework archive (pre-installed on macOS)
- **swift**: For calculating checksums (part of Xcode)
- **gh CLI**: For creating GitHub releases (optional but recommended)
  ```bash
  brew install gh
  gh auth login
  ```

### Check for New Versions

1. Visit the [MoltenVK Releases page](https://github.com/KhronosGroup/MoltenVK/releases)
2. Look for the latest release version (e.g., `v1.4.1`, `v1.5.0`)
3. Note the release date and verify it includes macOS binaries

## Update Procedure

### Step 1: Download New MoltenVK Release

Replace `v1.4.1` with your target version:

```bash
# Set the target version
export MOLTENVK_VERSION="v1.4.1"

# Download the macOS release
curl -L "https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-macos.tar" \
  -o MoltenVK-macos.tar
```

**Optional**: If you want iOS/tvOS support, download those archives as well:
```bash
# Download iOS release
curl -L "https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-ios.tar" \
  -o MoltenVK-ios.tar

# Download tvOS release (if available)
curl -L "https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-tvos.tar" \
  -o MoltenVK-tvos.tar
```

### Step 2: Extract and Locate the Static Framework

```bash
# Extract the archive
tar -xf MoltenVK-macos.tar

# The static framework should be at:
# MoltenVK/MoltenVK/static/MoltenVK.xcframework
```

**Important**: Verify you're using the **static** version (`.a` libraries), not the dynamic version (`.dylib`). The path should contain `/static/` in it.

```bash
# Verify it's the static version
find MoltenVK -name "*.a" | head -3
# Should show paths like: MoltenVK/MoltenVK/static/MoltenVK.xcframework/macos-arm64_x86_64/libMoltenVK.a

# Should NOT find .dylib files
find MoltenVK/MoltenVK/static/MoltenVK.xcframework -name "*.dylib"
# Should return nothing
```

### Step 3: Copy the New Framework

```bash
# Remove old framework if it exists
rm -rf MoltenVK.xcframework

# Copy the new static framework
cp -R MoltenVK/MoltenVK/static/MoltenVK.xcframework ./

# Verify the structure
ls -la MoltenVK.xcframework/
```

### Step 4: Create ZIP Archive

```bash
# Create a ZIP file for GitHub releases
zip -r MoltenVK.xcframework.zip MoltenVK.xcframework

# Verify the ZIP was created
ls -lh MoltenVK.xcframework.zip
```

### Step 5: Calculate Checksum

```bash
# Calculate SHA256 checksum
CHECKSUM=$(swift package compute-checksum MoltenVK.xcframework.zip)
echo "Checksum: $CHECKSUM"

# Save checksum for later
echo "$CHECKSUM" > checksum.txt
```

### Step 6: Update Version Information

#### 6.1 Update `.MoltenVK-version` File

Edit `.MoltenVK-version` and update the following fields:

```bash
# Example for updating to v1.4.1
cat > .MoltenVK-version << EOF
Version: ${MOLTENVK_VERSION}
Release Date: $(date +%Y-%m-%d)
Source: https://github.com/KhronosGroup/MoltenVK/releases/tag/${MOLTENVK_VERSION}
Download URL: https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-macos.tar
Type: Static (.a)
Architecture: macOS arm64_x86_64 (Universal)

Vulkan API Version: 1.4.323
Package Created: $(date +%Y-%m-%d)

Distribution: Binary-only (GitHub Releases)
Repository: https://github.com/susieyy/MoltenVK-XCFramework
EOF
```

#### 6.2 Update README.md

Update the version numbers in `README.md`:

```markdown
## Features

- **MoltenVK v1.4.1** - Vulkan implementation for Apple platforms
```

Search for all occurrences of the old version and update:
```bash
# Find all version references
grep -n "v1.4.0" README.md
```

### Step 7: Commit Version Updates

```bash
# Commit the version file and README updates
git add .MoltenVK-version README.md
git commit -m "Prepare for MoltenVK ${MOLTENVK_VERSION} update

- Updated .MoltenVK-version metadata
- Updated README.md version references

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push the commit
git push origin main
```

### Step 8: Create GitHub Release

#### Option A: Using GitHub CLI (Recommended)

```bash
# Create a new release and upload the xcframework
gh release create ${MOLTENVK_VERSION} \
  MoltenVK.xcframework.zip \
  --title "MoltenVK ${MOLTENVK_VERSION}" \
  --notes "Binary distribution of MoltenVK ${MOLTENVK_VERSION}

## Changes
- Updated to MoltenVK ${MOLTENVK_VERSION}
- Static library (`.a`) for macOS (arm64 + x86_64)

## Checksum
\`\`\`
$(cat checksum.txt)
\`\`\`

## Installation
Add to your Package.swift:
\`\`\`swift
.package(url: \"https://github.com/susieyy/MoltenVK-XCFramework.git\", from: \"${MOLTENVK_VERSION#v}\")
\`\`\`

---
For more information, see [MoltenVK Release Notes](https://github.com/KhronosGroup/MoltenVK/releases/tag/${MOLTENVK_VERSION})"
```

#### Option B: Manual Upload via GitHub Web UI

1. Go to https://github.com/susieyy/MoltenVK-XCFramework/releases/new
2. Create a new tag: `${MOLTENVK_VERSION}` (e.g., `v1.4.1`)
3. Set release title: `MoltenVK ${MOLTENVK_VERSION}`
4. Add release description (see template above)
5. Upload `MoltenVK.xcframework.zip` as a release asset
6. Publish the release

### Step 9: Update Package.swift with Release URL

```bash
# Get the release download URL
RELEASE_URL="https://github.com/susieyy/MoltenVK-XCFramework/releases/download/${MOLTENVK_VERSION}/MoltenVK.xcframework.zip"

# Read the checksum
CHECKSUM=$(cat checksum.txt)

# Update Package.swift
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
        .library(
            name: "MoltenVK",
            targets: ["MoltenVK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "MoltenVK",
            url: "$RELEASE_URL",
            checksum: "$CHECKSUM"
        ),
    ]
)
EOF
```

### Step 10: Validate the Update

#### 10.1 Test Package Resolution

```bash
# Clear package cache
rm -rf .build
rm Package.resolved

# Resolve dependencies (this will download from GitHub)
swift package resolve

# Verify it downloads and validates correctly
```

#### 10.2 Test in a Sample Project

Create a test project to verify the package works:

```bash
# Create a temporary test directory
mkdir -p /tmp/test-moltenvk && cd /tmp/test-moltenvk

# Create a simple Package.swift
cat > Package.swift << 'EOF'
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "TestMoltenVK",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/susieyy/MoltenVK-XCFramework.git", from: "1.4.1")
    ],
    targets: [
        .executableTarget(
            name: "TestMoltenVK",
            dependencies: [
                .product(name: "MoltenVK", package: "MoltenVK-XCFramework")
            ]
        )
    ]
)
EOF

# Try to build
swift build
```

### Step 11: Commit Package.swift Update

```bash
# Commit the updated Package.swift
git add Package.swift
git commit -m "Update Package.swift for MoltenVK ${MOLTENVK_VERSION} release

- Updated binaryTarget URL to ${MOLTENVK_VERSION} release
- Updated checksum: ${CHECKSUM}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push the commit
git push origin main
```

### Step 12: Cleanup

```bash
# Remove downloaded and temporary files
rm -rf MoltenVK-macos.tar MoltenVK/
rm -rf MoltenVK.xcframework/ MoltenVK.xcframework.zip
rm checksum.txt
```

## Multi-Platform Support (Advanced)

If you want to add iOS/tvOS support to create a multi-platform xcframework:

### Step 1: Download All Platform Archives

```bash
# Download all platforms
curl -L "https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-macos.tar" -o MoltenVK-macos.tar
curl -L "https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-ios.tar" -o MoltenVK-ios.tar
curl -L "https://github.com/KhronosGroup/MoltenVK/releases/download/${MOLTENVK_VERSION}/MoltenVK-tvos.tar" -o MoltenVK-tvos.tar

# Extract all
tar -xf MoltenVK-macos.tar -C macos
tar -xf MoltenVK-ios.tar -C ios
tar -xf MoltenVK-tvos.tar -C tvos
```

### Step 2: Combine into Multi-Platform XCFramework

```bash
# Use xcodebuild to create a multi-platform xcframework
xcodebuild -create-xcframework \
  -framework macos/MoltenVK/MoltenVK/static/MoltenVK.xcframework/macos-arm64_x86_64 \
  -framework ios/MoltenVK/MoltenVK/static/MoltenVK.xcframework/ios-arm64 \
  -framework ios/MoltenVK/MoltenVK/static/MoltenVK.xcframework/ios-arm64_x86_64-simulator \
  -framework tvos/MoltenVK/MoltenVK/static/MoltenVK.xcframework/tvos-arm64 \
  -framework tvos/MoltenVK/MoltenVK/static/MoltenVK.xcframework/tvos-arm64-simulator \
  -output MoltenVK.xcframework
```

### Step 3: Update Package.swift Platforms

```swift
platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
],
```

## Troubleshooting

### Issue: Checksum Mismatch

**Symptom**: Package resolution fails with checksum error

**Solution**:
1. Verify the ZIP file was created correctly
2. Recalculate the checksum: `swift package compute-checksum MoltenVK.xcframework.zip`
3. Update Package.swift with the correct checksum
4. Make sure you didn't modify the ZIP after calculating the checksum

### Issue: Release Asset Not Found

**Symptom**: Package resolution fails with 404 error

**Solution**:
1. Verify the release was created on GitHub
2. Check that the ZIP file was uploaded as an asset
3. Ensure the URL in Package.swift matches the actual release URL
4. Make sure the release is published (not a draft)

### Issue: Binary Not Loading

**Symptom**: Runtime errors about missing libraries

**Solution**:
1. Verify you used the **static** version (`.a` files)
2. Check that the xcframework contains the correct architectures
3. Ensure you're testing on a supported platform (macOS 13.0+)

### Issue: Package.swift Syntax Error

**Symptom**: Swift package resolution fails with parse error

**Solution**:
```bash
# Validate Package.swift syntax
swift package dump-package

# This will show any syntax errors
```

## Best Practices

1. **Always use static libraries** - Dynamic libraries require code signing
2. **Test before releasing** - Create and test the release in a clean environment
3. **Document changes** - Include release notes with each version
4. **Verify checksums** - Double-check checksums before committing Package.swift
5. **Tag releases properly** - Use semantic versioning (e.g., v1.4.1)
6. **Keep assets small** - Use ZIP compression to reduce download size
7. **No Git LFS needed** - GitHub Releases handles large files natively

## Version Consistency Checklist

Before finalizing an update, verify all version references are consistent:

- [ ] `.MoltenVK-version` file updated
- [ ] `README.md` version references updated
- [ ] GitHub release created with correct tag
- [ ] `MoltenVK.xcframework.zip` uploaded to release
- [ ] `Package.swift` URL points to new release
- [ ] `Package.swift` checksum matches the uploaded ZIP
- [ ] Changes committed and pushed
- [ ] Package resolves correctly in test project
- [ ] All platforms build successfully (if multi-platform)

## References

- [MoltenVK Releases](https://github.com/KhronosGroup/MoltenVK/releases)
- [MoltenVK Documentation](https://github.com/KhronosGroup/MoltenVK/tree/main/Docs)
- [Swift Package Manager - Binary Targets](https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md#binary-targets)
- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)

## Notes

- **No Git LFS required** - This package uses GitHub Releases for binary distribution
- **Small repository** - Only source files are in the repository (Package.swift, docs)
- **Fast cloning** - Users don't download the binary until package resolution
- **Version flexibility** - Easy to maintain multiple versions via releases
- **Platform scalability** - Can add iOS/tvOS/visionOS support without changing workflow
