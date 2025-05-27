# `.github/workflows/review.yml` レビュー

## 概要

このファイルは、プルリクエストが作成されたときや「レビュー準備完了」状態になったときに、自動的にレビュアーを割り当てるGitHub Actionsワークフローを定義しています。

## レビュー内容

### 設計と構造

- ✅ **基本構造**: シンプルな単一ジョブのワークフローで、標準的なGitHub Actionsの構造に従っています。
- ✅ **トリガー設定**: プルリクエストの作成時（`opened`）と「レビュー準備完了」状態（`ready_for_review`）になったときに実行されるよう適切に設定されています。
- ✅ **パーミッション設定**: 必要最小限の権限（コンテンツの読み取りとプルリクエストの書き込み）のみが付与されています。

### 機能性

- ✅ **アクション選択**: `kentaro-m/auto-assign-action@v2.0.0` を使用して、レビュアーの自動割り当てを実装しています。
- ✅ **設定ファイル参照**: `.github/review-config.yml` から設定を読み込むよう適切に構成されています。

### 関連ファイル（`.github/review-config.yml`）

- ✅ **レビュアー設定**: `LunaRabbit66` と `book000` の2名がレビュアーとして設定されています。
- ✅ **アサイン設定**: `addReviewers: true` でレビュアーの追加が有効化され、`addAssignees: false` でアサインは無効化されています。

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

## セキュリティ

- ✅ **Pull Request Target**: `pull_request_target` トリガーを使用していますが、機密情報へのアクセスは最小限に制限されています。
- ✅ **最小権限**: 必要な権限のみが設定されており、適切なセキュリティプラクティスに従っています。

## パフォーマンス

- ✅ **軽量なワークフロー**: シンプルな単一ジョブで構成されており、リソース使用量が最小限に抑えられています。

## 結論

このレビュー自動割り当てワークフローは、基本的な機能を効率的に実行しています。提案した改善点は、より柔軟なレビュー割り当てや通知機能の追加など、オプションの拡張です。現状でも、プルリクエストにレビュアーを自動的に割り当てるという主要な目的は達成されています。
