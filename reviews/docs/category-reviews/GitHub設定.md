# GitHub設定 カテゴリのレビュー

このカテゴリには以下の 4 ファイルが含まれています：
## S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.github\review-config.yml.md

このファイルは、プルリクエストに対する自動レビュアー割り当てを設定するYAMLファイルです。`.github/workflows/review.yml` ワークフローから参照され、プルリクエストが作成されたときに誰をレビュアーとして割り当てるかを定義しています。

### 良い点

- ✅ **設定項目**: レビュアー追加の有効化、アサイン（担当者）追加の無効化、およびレビュアーリストが適切に定義されています。

### 改善提案

1. **レビュアー数の制限**: 割り当てるレビュアーの数を指定することで、すべてのレビュアーではなく一部のみを割り当てることができます。

```yaml
addReviewers: true
addAssignees: false
numberOfReviewers: 1  # プルリクエストごとに1名のレビュアーのみを割り当て
reviewers:
  - LunaRabbit66
  - book000
```

2. **特定キーワードによるスキップ**: WIPやドラフトなど、特定のキーワードを含むプルリクエストに対してはレビュアーを割り当てないようにできます。

```yaml
addReviewers: true
addAssignees: false
reviewers:
  - LunaRabbit66
  - book000
skipKeywords:
  - wip
  - draft
  - [WIP]
```

3. **ファイルパスに基づいたレビュアーの割り当て**: 変更されたファイルのパスに応じて、異なるレビュアーを割り当てることができます。

```yaml
addReviewers: true
addAssignees: false
reviewers:
  - LunaRabbit66
  - book000
useReviewGroups: true
reviewGroups:
  core:
    - LunaRabbit66
    - book000
  ui:
    - ui-expert
filePathPatterns:
  'RNGNewAuraNotifier/UI/**/*':
    reviewers:
      - ui-expert
  'RNGNewAuraNotifier/Core/**/*':
    reviewers:
      - core-expert
```

4. **レビュアーグループの使用**: 特定の部分に詳しいレビュアーのグループを定義できます。

```yaml
addReviewers: true
addAssignees: false
useReviewGroups: true
reviewGroups:
  core-team:
    - LunaRabbit66
    - book000
  ui-team:
    - ui-reviewer1
  backend-team:
    - backend-reviewer1
numberOfReviewers: 1
numberOfReviewGroups: 1
```

---

## S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.github\workflows\ci.yml.md

このファイルは、GitHub Actions を使用したCI（継続的インテグレーション）ワークフローを定義しています。メインブランチへのプッシュおよびプルリクエスト時に自動的に実行され、ビルド、パッケージの復元、コードスタイルのチェックなどを行います。

### 良い点

- ✅ **トリガー設定**: mainとmasterブランチへのプッシュおよびプルリクエスト時に実行される適切なトリガーが設定されています。
- ✅ **ジョブ構成**: 単一の「build」ジョブで、すべての必要なステップが論理的に構成されています。

### 改善提案

1. **テストの追加**: ユニットテストやインテグレーションテストを実行するステップを追加すると、コードの品質保証が向上します。

```yaml
- name: Run tests
  run: dotnet test RNGNewAuraNotifier.sln --configuration Release --no-build
```

2. **キャッシュの活用**: 依存関係のキャッシュを活用して、ビルド時間を短縮できます。

```yaml
- name: Cache NuGet packages
  uses: actions/cache@v3
  with:
    path: ~/.nuget/packages
    key: ${{ runner.os }}-nuget-${{ hashFiles('**/packages.lock.json') }}
    restore-keys: |
      ${{ runner.os }}-nuget-
```

3. **マトリックスビルド**: 複数の.NETバージョンやOSでのテストを追加することで、互換性を確保できます。

```yaml
jobs:
  build:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [windows-latest, ubuntu-latest]
        dotnet-version: ['9.0.x', '8.0.x']
```

4. **依存関係の脆弱性スキャン**: セキュリティスキャンを追加して、依存関係の脆弱性を検出できます。

```yaml
- name: Run security scan
  uses: snyk/actions/dotnet@master
  with:
    args: --severity-threshold=high
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

5. **コードカバレッジの追加**: テストのコードカバレッジを測定し、レポートを生成するステップを追加できます。

```yaml
- name: Generate code coverage
  run: dotnet test RNGNewAuraNotifier.sln /p:CollectCoverage=true /p:CoverletOutputFormat=opencover

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
```

---

## S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.github\workflows\release.yml.md

このファイルは、GitHub Actions を使用した自動リリースワークフローを定義しています。メインブランチへのプッシュ時または手動トリガー時に実行され、バージョンのバンプ、ビルド、リリースパッケージの作成、GitHub Releaseの公開を自動化します。

### 良い点

- ✅ **トリガー設定**: mainとmasterブランチへのプッシュ時、または手動トリガー時に実行される設定になっています。
- ✅ **同時実行制御**: `concurrency` 設定により、同じブランチで複数のワークフローが同時に実行されるのを防いでいます。

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

---

## S:\Git\CSharpProjects\RNGNewAuraNotifier\reviews\results\.github\workflows\review.yml.md

このファイルは、プルリクエストが作成されたときや「レビュー準備完了」状態になったときに、自動的にレビュアーを割り当てるGitHub Actionsワークフローを定義しています。

### 良い点

- ✅ **トリガー設定**: プルリクエストの作成時（`opened`）と「レビュー準備完了」状態（`ready_for_review`）になったときに実行されるよう適切に設定されています。
- ✅ **パーミッション設定**: 必要最小限の権限（コンテンツの読み取りとプルリクエストの書き込み）のみが付与されています。

### 改善提案

1. **トリガーの拡張**: 追加のイベントタイプを含めることで、より多くのシナリオでレビュアーを割り当てることができます。

```yaml
on:
  pull_request_target:
    types: [opened, ready_for_review, reopened, synchronize]
```

2. **レビュアー設定のカスタマイズ**: より詳細なレビュアー割り当てルールを設定することを検討できます。

```yaml
# .github/review-config.yml の改善例
addReviewers: true
addAssignees: false
reviewers:
  - LunaRabbit66
  - book000
numberOfReviewers: 1  # 必要なレビュアーの数を制限
skipKeywords:
  - wip
  - draft
useReviewGroups: true  # チームベースのレビューグループを使用
reviewGroups:
  core-team:
    - LunaRabbit66
    - book000
  ui-team:
    - ui-reviewer1
    - ui-reviewer2
filePathPatterns:
  'RNGNewAuraNotifier/UI/**/*':
    - ui-team
  '**/*':
    - core-team
```

3. **レビュー割り当て後の通知**: レビュー割り当て後にチャットツール（SlackやDiscord）などへの通知を追加することで、レビュープロセスを効率化できます。

```yaml
jobs:
  add-reviews:
    runs-on: ubuntu-latest
    steps:
      - uses: kentaro-m/auto-assign-action@v2.0.0
        with:
          configuration-path: '.github/review-config.yml'

      - name: Notify on Discord
        if: success()
        uses: Ilshidur/action-discord@master
        with:
          args: 'プルリクエスト #${{ github.event.pull_request.number }} にレビュアーが割り当てられました。'
        env:
          DISCORD_WEBHOOK: ${{ secrets.DISCORD_WEBHOOK }}
```

---


