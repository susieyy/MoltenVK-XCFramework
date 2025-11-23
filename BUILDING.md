# マルチプラットフォーム XCFramework ビルドガイド

このガイドでは、自動化スクリプトを使用して MoltenVK のマルチプラットフォーム XCFramework（macOS + iOS デバイス + iOS シミュレーター）をビルドする方法を説明します。

## 概要

提供されるスクリプト：

1. **build-multiplatform-xcframework.sh** - マルチプラットフォーム XCFramework をビルドするメインスクリプト
2. **update-package-swift.sh** - Package.swift を新しいリリースで更新するヘルパースクリプト

## 前提条件

- macOS (Xcode がインストールされていること)
- Swift 6.2+
- `gh` CLI（GitHub リリース作成用、オプション）
  ```bash
  brew install gh
  gh auth login
  ```

## 使用方法

### ステップ 1: マルチプラットフォーム XCFramework のビルド

メインスクリプトを実行して、マルチプラットフォーム XCFramework を作成します：

```bash
# デフォルトバージョン (v1.4.0) を使用
./build-multiplatform-xcframework.sh

# または、特定のバージョンを指定
MOLTENVK_VERSION=v1.4.0 ./build-multiplatform-xcframework.sh
```

このスクリプトは以下を実行します：

1. ✅ MoltenVK の全プラットフォームアーカイブ（MoltenVK-all.tar）をダウンロード
2. ✅ アーカイブを展開
3. ✅ マルチプラットフォーム XCFramework を作成
   - macOS (arm64 + x86_64)
   - iOS デバイス (arm64)
   - iOS シミュレーター (arm64 + x86_64)
4. ✅ XCFramework を ZIP 化
5. ✅ チェックサムを計算して `checksum.txt` に保存
6. ✅ `.MoltenVK-version` を更新

### ステップ 2: GitHub リリースの作成

スクリプト完了後、GitHub リリースを作成します：

#### オプション A: GitHub CLI を使用（推奨）

```bash
# スクリプトが表示するコマンドを実行
gh release create 1.4.0 MoltenVK.xcframework.zip \
  --title "MoltenVK 1.4.0 with iOS Support" \
  --notes "Multi-platform binary including macOS and iOS (device + simulator)

## Platform Support
- macOS (arm64 + x86_64)
- iOS Device (arm64)
- iOS Simulator (arm64 + x86_64)

## Installation
Add to your Package.swift:
\`\`\`swift
dependencies: [
    .package(url: \"https://github.com/susieyy/MoltenVK-XCFramework.git\", from: \"1.4.0\")
]
\`\`\`

## Checksum
\`\`\`
$(cat checksum.txt)
\`\`\`

---
Based on [KhronosGroup/MoltenVK v1.4.0](https://github.com/KhronosGroup/MoltenVK/releases/tag/v1.4.0)"
```

#### オプション B: GitHub Web UI を使用

1. https://github.com/susieyy/MoltenVK-XCFramework/releases/new にアクセス
2. タグを作成: `1.4.0`（**'v' プレフィックスなし** - SPM 互換性のため）
3. リリースタイトル: `MoltenVK 1.4.0 with iOS Support`
4. `MoltenVK.xcframework.zip` をアセットとしてアップロード
5. リリースを公開

### ステップ 3: Package.swift の更新

リリース作成後、Package.swift を更新します：

```bash
# checksum.txt からチェックサムを読み込んで更新
./update-package-swift.sh 1.4.0 "$(cat checksum.txt)"
```

または手動で Package.swift を編集：
- `url`: 新しいリリース URL に更新
- `checksum`: `checksum.txt` の値に更新

### ステップ 4: 検証

パッケージが正しく解決されることを確認：

```bash
# キャッシュをクリア
rm -rf .build Package.resolved

# パッケージを解決（GitHub からダウンロード）
swift package resolve

# ビルドをテスト
swift build
```

### ステップ 5: README.md の更新

README.md の Platform Support セクションを更新して、iOS サポートを反映：

```markdown
## Platform Support

Currently supports:
- macOS (arm64 + x86_64 universal binary)
- iOS Device (arm64)
- iOS Simulator (arm64 + x86_64)
```

### ステップ 6: コミットとプッシュ

```bash
# 変更をコミット
git add Package.swift .MoltenVK-version README.md
git commit -m "Add iOS device and simulator support

- Updated to multi-platform XCFramework
- Includes macOS + iOS device + iOS simulator
- Updated Package.swift with new release URL and checksum

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# プッシュ
git push origin main
```

## 生成されるファイル

スクリプト実行後、以下のファイルが生成/更新されます：

- `MoltenVK.xcframework/` - マルチプラットフォーム XCFramework
- `MoltenVK.xcframework.zip` - リリース用 ZIP ファイル
- `checksum.txt` - Swift Package Manager チェックサム
- `.MoltenVK-version` - 更新されたバージョン情報
- `build-xcframework/` - 作業ディレクトリ（削除可）
- `MoltenVK.xcframework.backup` - 元のフレームワークのバックアップ（存在した場合）
- `Package.swift.backup` - Package.swift のバックアップ

## クリーンアップ

完了後、不要なファイルを削除：

```bash
# 作業ディレクトリを削除
rm -rf build-xcframework/

# バックアップを削除
rm -f MoltenVK.xcframework.backup Package.swift.backup

# チェックサムファイルは保持するか削除（お好みで）
# rm checksum.txt
```

## トラブルシューティング

### xcodebuild が見つからない

**症状**: `xcodebuild: command not found`

**解決策**: Xcode がインストールされていることを確認し、コマンドラインツールを設定：
```bash
xcode-select --install
sudo xcode-select --switch /Applications/Xcode.app
```

### チェックサムミスマッチ

**症状**: パッケージ解決時にチェックサムエラー

**解決策**:
1. チェックサムを再計算: `swift package compute-checksum MoltenVK.xcframework.zip`
2. Package.swift を正しいチェックサムで更新
3. ZIP ファイルをチェックサム計算後に変更していないことを確認

### リリースアセットが見つからない

**症状**: パッケージ解決時に 404 エラー

**解決策**:
1. GitHub でリリースが公開されていることを確認
2. ZIP ファイルがアセットとしてアップロードされていることを確認
3. Package.swift の URL がリリース URL と一致することを確認
4. タグに 'v' プレフィックスがないことを確認（`1.4.0` ○、`v1.4.0` ×）

## 参考資料

- [UPDATING.md](UPDATING.md) - 完全な更新手順
- [MoltenVK Releases](https://github.com/KhronosGroup/MoltenVK/releases)
- [Swift Package Manager - Binary Targets](https://github.com/apple/swift-package-manager/blob/main/Documentation/Usage.md#binary-targets)

## 重要な注意事項

- **タグ形式**: SPM 互換性のため、GitHub リリースタグには 'v' プレフィックスを**付けない**でください（`1.4.0` を使用、`v1.4.0` は不可）
- **静的ライブラリ**: スクリプトは自動的に静的バージョン（`.a` ファイル）を使用します
- **バックアップ**: スクリプトは既存のファイルを上書きする前に自動的にバックアップを作成します
