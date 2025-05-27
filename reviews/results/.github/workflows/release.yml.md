# `.github/workflows/release.yml` レビュー

## 概要

このファイルは、GitHub Actions を使用した自動リリースワークフローを定義しています。メインブランチへのプッシュ時または手動トリガー時に実行され、バージョンのバンプ、ビルド、リリースパッケージの作成、GitHub Releaseの公開を自動化します。

## レビュー内容

### 設計と構造

- ✅ **基本構造**: ワークフローは論理的に分割された2つのジョブ（バージョンバンプとビルド・リリース）で構成されています。
- ✅ **トリガー設定**: mainとmasterブランチへのプッシュ時、または手動トリガー時に実行される設定になっています。
- ✅ **同時実行制御**: `concurrency` 設定により、同じブランチで複数のワークフローが同時に実行されるのを防いでいます。

### 機能性

#### バージョンバンプジョブ (`bump-version`)

- ✅ **アクション選択**: `mathieudutour/github-tag-action@v6.2` を使用して、セマンティックバージョニングに基づいたバージョン管理を実装しています。
- ✅ **カスタムリリースルール**: コミットメッセージのプレフィックスに基づいて適切なバージョンバンプ（major/minor/patch）を行うルールが設定されています。
- ✅ **出力変数**: 新しいバージョン、タグ、変更ログを次のジョブで使用するために出力しています。

#### ビルド・リリースジョブ (`build-and-release`)

- ✅ **環境設定**: Windows環境で.NET 9.0を使用するよう適切に設定されています。
- ✅ **バージョン適用**: PowerShellスクリプトを使用して、プロジェクトファイルのバージョン情報を更新しています。
- ✅ **ビルドプロセス**: ソリューションのリストア、ビルド、公開が適切に行われています。
- ✅ **パッケージ作成**: ビルド成果物をZIPファイルにまとめています。
- ✅ **リリース公開**: `softprops/action-gh-release@v2` を使用して、GitHub Releaseを作成・公開しています。

### 改善提案

1. **バージョン検証**: バージョン更新前後の検証ステップを追加することで、予期せぬエラーを防止できます。

```yaml
- name: Verify version update
  run: |
    $mainProj = Get-Content .\RNGNewAuraNotifier\RNGNewAuraNotifier.csproj
    $updaterProj = Get-Content .\RNGNewAuraNotifier.Updater\RNGNewAuraNotifier.Updater.csproj
    if ($mainProj -notmatch "<Version>$env:APP_VERSION</Version>" -or $updaterProj -notmatch "<Version>$env:APP_VERSION</Version>") {
      Write-Error "Version update failed"
      exit 1
    }
  shell: pwsh
  env:
    APP_VERSION: ${{ needs.bump-version.outputs.version }}
```

2. **リリースノート改善**: 変更ログからより詳細なリリースノートを生成するステップを追加できます。

```yaml
- name: Generate detailed release notes
  id: release-notes
  run: |
    $changelog = @"
    ## 変更内容

    ${{ needs.bump-version.outputs.changelog }}

    ## インストール方法

    1. このリリースからZIPファイルをダウンロード
    2. 任意のフォルダに展開
    3. RNGNewAuraNotifier.exeを実行

    ## 既知の問題

    なし
    "@
    $changelog = $changelog -replace "`n", "%0A"
    echo "::set-output name=notes::$changelog"
  shell: pwsh

# リリース公開時に詳細なリリースノートを使用
- name: Publish Release
  uses: softprops/action-gh-release@v2
  with:
    body: ${{ steps.release-notes.outputs.notes }}
    tag_name: ${{ needs.bump-version.outputs.tag }}
    # ...
```

3. **テスト実行**: リリース前にテストを実行するステップを追加することで、品質保証を強化できます。

```yaml
- name: Run tests
  run: dotnet test RNGNewAuraNotifier.sln --configuration Release
```

4. **署名の追加**: リリースバイナリにコード署名を追加することで、セキュリティと信頼性を向上させることができます。

```yaml
- name: Sign binaries
  uses: microsoft/signtool-action@v1.0
  with:
    certificate: ${{ secrets.CODE_SIGNING_CERT }}
    password: ${{ secrets.CERT_PASSWORD }}
    folder: "bin/Publish"
    recursive: true
```

5. **チェックサム生成**: ダウンロードの整合性検証用にチェックサムファイルを生成できます。

```yaml
- name: Generate checksum
  run: |
    $filePath = "RNGNewAuraNotifier.zip"
    $hash = Get-FileHash -Path $filePath -Algorithm SHA256
    $hash.Hash | Out-File -FilePath "RNGNewAuraNotifier.zip.sha256" -Encoding utf8
  shell: pwsh

# チェックサムファイルもリリースに含める
- name: Publish Release
  uses: softprops/action-gh-release@v2
  with:
    # ...
    files: |
      RNGNewAuraNotifier.zip
      RNGNewAuraNotifier.zip.sha256
```

## セキュリティ

- ✅ **トークン使用**: 標準のGitHubトークン（`secrets.GITHUB_TOKEN`）を使用しており、適切なセキュリティプラクティスに従っています。
- ⚠️ **コード署名なし**: 現在、リリースバイナリには署名がありません。署名を追加することで、エンドユーザーに対するセキュリティと信頼性を向上させることができます。

## パフォーマンス

- ✅ **並列ジョブ**: バージョンバンプとビルド・リリースが別々のジョブに分割されており、効率的なワークフロー実行を可能にしています。
- ⚠️ **アーティファクトキャッシュなし**: 依存関係のキャッシュを活用していないため、毎回すべてのパッケージをダウンロードする必要があります。

## 結論

このリリースワークフローは、バージョン管理、ビルド、パッケージング、公開を効率的に自動化しています。テスト実行、署名、チェックサム生成などの追加機能を導入することで、より堅牢で信頼性の高いリリースプロセスを構築できるでしょう。また、詳細なリリースノートを生成することで、エンドユーザーにとってより有用な情報を提供できます。
