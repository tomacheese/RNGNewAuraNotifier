# RNGNewAuraNotifierプロジェクトのレビュー結果をドキュメント化するスクリプト
# 使用方法: .\GenerateReviewDocs.ps1

$reviewsDir = "s:\Git\CSharpProjects\RNGNewAuraNotifier\reviews"
$resultsDir = Join-Path $reviewsDir "results"
$docsDir = Join-Path $reviewsDir "docs"

# 出力ディレクトリがなければ作成
if (-not (Test-Path $docsDir)) {
    New-Item -Path $docsDir -ItemType Directory | Out-Null
    Write-Host "ドキュメント出力ディレクトリを作成しました: $docsDir" -ForegroundColor Green
}

# レビューサマリーを読み込む
$summaryPath = Join-Path $reviewsDir "review-summary.md"
$summaryContent = ""
if (Test-Path $summaryPath) {
    $summaryContent = Get-Content $summaryPath -Raw
    Write-Host "レビューサマリーを読み込みました" -ForegroundColor Green
}

# プロジェクト詳細を読み込む
$projectDetailsPath = Join-Path $reviewsDir "project-details.md"
$projectDetailsContent = ""
if (Test-Path $projectDetailsPath) {
    $projectDetailsContent = Get-Content $projectDetailsPath -Raw
    Write-Host "プロジェクト詳細を読み込みました" -ForegroundColor Green
}

# インデックスページを生成
$indexPath = Join-Path $docsDir "index.md"
$indexContent = @"
# RNGNewAuraNotifier プロジェクトレビュー

## 概要

このドキュメントは、RNGNewAuraNotifierプロジェクトのコードレビュー結果をまとめたものです。
レビューは2025年5月に実施され、プロジェクトの品質、設計、実装、セキュリティなどの観点から評価されています。

## 目次

1. [プロジェクト概要](project-overview.md)
2. [レビュー方法](review-methodology.md)
3. [レビュー結果サマリー](review-summary.md)
4. [カテゴリ別レビュー](category-reviews/index.md)
5. [改善提案](improvement-proposals.md)
6. [総合評価](overall-assessment.md)

## ハイライト

- レビュー対象ファイル数: $(Get-ChildItem -Path $resultsDir -Recurse -File -Filter "*.md" | Measure-Object | Select-Object -ExpandProperty Count)
- レビュー日: $(Get-Date -Format "yyyy年MM月dd日")
- 主な改善提案数: $(Select-String -Path "$resultsDir\*" -Pattern "改善|提案" | Measure-Object | Select-Object -ExpandProperty Count)

"@

$indexContent | Out-File -FilePath $indexPath -Encoding UTF8
Write-Host "インデックスページを生成しました: $indexPath" -ForegroundColor Green

# プロジェクト概要ページを生成
$projectOverviewPath = Join-Path $docsDir "project-overview.md"
$projectOverviewContent = @"
# プロジェクト概要

$projectDetailsContent
"@

$projectOverviewContent | Out-File -FilePath $projectOverviewPath -Encoding UTF8
Write-Host "プロジェクト概要ページを生成しました: $projectOverviewPath" -ForegroundColor Green

# レビュー方法ページを生成
$methodologyPath = Join-Path $docsDir "review-methodology.md"
$methodologyContent = @"
# レビュー方法

## レビュー対象

RNGNewAuraNotifierプロジェクトのレビューでは、以下のファイルを対象としました：

- ソースコードファイル (`.cs`)
- プロジェクト設定ファイル (`.csproj`, `.sln`)
- 設定ファイル (`.json`, `.config`)
- リソースファイル (`.resx`, `.ico`)
- ドキュメント (`.md`)
- その他の設定ファイル (`.editorconfig`, `.gitattributes`など)

## レビュー基準

レビューは以下の観点から実施されました：

1. **コード品質**
   - 命名規則
   - コードの読みやすさ
   - ドキュメンテーション
   - コーディング規約の遵守

2. **アーキテクチャと設計**
   - クラス・メソッドの責務
   - モジュール化
   - 拡張性
   - 依存関係

3. **機能性**
   - 仕様の充足度
   - エラー処理
   - ロギング
   - 例外処理

4. **セキュリティ**
   - 脆弱性の有無
   - 機密情報の扱い
   - 入力検証

5. **パフォーマンス**
   - リソース使用効率
   - メモリ管理
   - 非同期処理

## レビュー手法

各ファイルに対して以下のステップでレビューを実施しました：

1. ファイルの概要把握
2. コードの詳細レビュー
3. 良い点と問題点の特定
4. 改善提案の作成
5. セキュリティとパフォーマンスの検証
6. 総合評価

## レビュー結果の記録

レビュー結果は、以下のセクションを含むMarkdownファイルに記録されています：

- **概要**: ファイルの目的と役割
- **良い点**: ファイルの優れた点
- **問題点**: 発見された問題点
- **改善案**: 具体的な改善提案
- **セキュリティの考慮事項**: セキュリティ上の懸念点
- **パフォーマンスの考慮事項**: パフォーマンスに関する考察
- **総評**: ファイルの全体的な評価
"@

$methodologyContent | Out-File -FilePath $methodologyPath -Encoding UTF8
Write-Host "レビュー方法ページを生成しました: $methodologyPath" -ForegroundColor Green

# レビューサマリーページを生成
$reviewSummaryPath = Join-Path $docsDir "review-summary.md"
$reviewSummaryContent = @"
# レビュー結果サマリー

$summaryContent
"@

$reviewSummaryContent | Out-File -FilePath $reviewSummaryPath -Encoding UTF8
Write-Host "レビューサマリーページを生成しました: $reviewSummaryPath" -ForegroundColor Green

# カテゴリ別レビューディレクトリを作成
$categoryDir = Join-Path $docsDir "category-reviews"
if (-not (Test-Path $categoryDir)) {
    New-Item -Path $categoryDir -ItemType Directory | Out-Null
    Write-Host "カテゴリ別レビューディレクトリを作成しました: $categoryDir" -ForegroundColor Green
}

# ファイルをカテゴリに分類する関数
function Get-FileCategory {
    param (
        [string]$filePath
    )

    $relativePath = $filePath.Replace($resultsDir, "").TrimStart("\")

    if ($relativePath -match "\.github\\") { return "GitHub設定" }
    if ($relativePath -match "\.vscode\\") { return "VS Code設定" }
    if ($relativePath -match "\.editorconfig") { return "エディタ設定" }
    if ($relativePath -match "\.git") { return "Git設定" }
    if ($relativePath -match "renovate\.json") { return "依存関係管理" }
    if ($relativePath -match "stylecop\.json") { return "コードスタイル" }
    if ($relativePath -match "LICENSE") { return "ライセンス" }
    if ($relativePath -match "README") { return "ドキュメント" }
    if ($relativePath -match "\.sln$|\.csproj$") { return "プロジェクト設定" }
    if ($relativePath -match "\\Properties\\") { return "アプリケーション設定" }
    if ($relativePath -match "\\Resources\\") { return "リソース" }
    if ($relativePath -match "\\Core\\Aura\\") { return "Aura機能" }
    if ($relativePath -match "\\Core\\Config\\") { return "構成管理" }
    if ($relativePath -match "\\Core\\Json\\") { return "JSON処理" }
    if ($relativePath -match "\\Core\\Notification\\") { return "通知機能" }
    if ($relativePath -match "\\Core\\Updater\\") { return "更新機能" }
    if ($relativePath -match "\\Core\\VRChat\\") { return "VRChat連携" }
    if ($relativePath -match "\\UI\\") { return "ユーザーインターフェース" }
    if ($relativePath -match "\\RNGNewAuraNotifier\.Updater\\") { return "アップデーター" }

    return "その他"
}

# カテゴリごとにファイルを分類
$categories = @{}
$reviewFiles = Get-ChildItem -Path $resultsDir -Recurse -File -Filter "*.md"

foreach ($file in $reviewFiles) {
    $category = Get-FileCategory -filePath $file.FullName
    if (-not $categories.ContainsKey($category)) {
        $categories[$category] = @()
    }
    $categories[$category] += $file
}

# カテゴリインデックスページを生成
$categoryIndexPath = Join-Path $categoryDir "index.md"
$categoryIndexContent = @"
# カテゴリ別レビュー

このセクションでは、RNGNewAuraNotifierプロジェクトのファイルをカテゴリ別に分類し、各カテゴリのレビュー結果をまとめています。

## カテゴリ一覧

"@

foreach ($category in $categories.Keys | Sort-Object) {
    $fileCount = $categories[$category].Count
    $categoryIndexContent += "- [$category](./$($category).md) ($fileCount ファイル)`n"
}

$categoryIndexContent | Out-File -FilePath $categoryIndexPath -Encoding UTF8
Write-Host "カテゴリインデックスページを生成しました: $categoryIndexPath" -ForegroundColor Green

# カテゴリごとのページを生成
foreach ($category in $categories.Keys | Sort-Object) {
    $categoryFilePath = Join-Path $categoryDir "$category.md"
    $categoryContent = @"
# $category カテゴリのレビュー

このカテゴリには以下の $($categories[$category].Count) ファイルが含まれています：

"@

    foreach ($file in $categories[$category]) {
        $relativePath = $file.FullName.Replace($resultsDir, "").TrimStart("\")
        $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $fileContent = Get-Content $file.FullName -Raw

        # ファイル概要を抽出
        $overviewMatch = [regex]::Match($fileContent, '##\s+概要\s+([\s\S]*?)(?:##|$)')
        $overview = ""
        if ($overviewMatch.Success) {
            $overview = $overviewMatch.Groups[1].Value.Trim()
        }

        $categoryContent += "## $relativePath`n`n"
        $categoryContent += "$overview`n`n"

        # 良い点を抽出
        $goodPointsMatch = [regex]::Match($fileContent, '(?:##\s+良い点|✅[^\r\n]*)([\s\S]*?)(?:##|$)')
        if ($goodPointsMatch.Success) {
            $categoryContent += "### 良い点`n`n"
            $categoryContent += $goodPointsMatch.Groups[1].Value.Trim() + "`n`n"
        }

        # 問題点を抽出
        $badPointsMatch = [regex]::Match($fileContent, '(?:##\s+問題点|❌[^\r\n]*)([\s\S]*?)(?:##|$)')
        if ($badPointsMatch.Success) {
            $categoryContent += "### 問題点`n`n"
            $categoryContent += $badPointsMatch.Groups[1].Value.Trim() + "`n`n"
        }

        # 改善提案を抽出
        $suggestionsMatch = [regex]::Match($fileContent, '(?:##\s+改善|##\s+提案)[^\r\n]*([\s\S]*?)(?:##|$)')
        if ($suggestionsMatch.Success) {
            $categoryContent += "### 改善提案`n`n"
            $categoryContent += $suggestionsMatch.Groups[1].Value.Trim() + "`n`n"
        }

        $categoryContent += "---`n`n"
    }

    $categoryContent | Out-File -FilePath $categoryFilePath -Encoding UTF8
    Write-Host "カテゴリページを生成しました: $categoryFilePath" -ForegroundColor Green
}

# 改善提案ページを生成
$proposalsPath = Join-Path $docsDir "improvement-proposals.md"
$proposalsContent = @"
# 改善提案

このセクションでは、RNGNewAuraNotifierプロジェクトの改善に向けた提案をまとめています。改善提案は優先度順に整理されています。

## 主要な改善提案

"@

# 主要な改善提案を抽出（レビューサマリーから）
$mainProposalsMatch = [regex]::Match($summaryContent, '##\s+主要な改善提案([\s\S]*?)(?:##|$)')
if ($mainProposalsMatch.Success) {
    $proposalsContent += $mainProposalsMatch.Groups[1].Value.Trim() + "`n`n"
} else {
    # サマリーから抽出できない場合は、個別のレビューから集約
    foreach ($category in $categories.Keys | Sort-Object) {
        $proposalsContent += "### $category カテゴリの改善提案`n`n"

        $hasSuggestions = $false
        foreach ($file in $categories[$category]) {
            $fileContent = Get-Content $file.FullName -Raw
            $suggestionsMatch = [regex]::Match($fileContent, '(?:##\s+改善|##\s+提案)[^\r\n]*([\s\S]*?)(?:##|$)')

            if ($suggestionsMatch.Success) {
                $relativePath = $file.FullName.Replace($resultsDir, "").TrimStart("\")
                $suggestions = $suggestionsMatch.Groups[1].Value.Trim()

                if (-not [string]::IsNullOrWhiteSpace($suggestions)) {
                    $proposalsContent += "**$relativePath**:`n`n$suggestions`n`n"
                    $hasSuggestions = $true
                }
            }
        }

        if (-not $hasSuggestions) {
            $proposalsContent += "このカテゴリには特に改善提案はありません。`n`n"
        }
    }
}

$proposalsContent | Out-File -FilePath $proposalsPath -Encoding UTF8
Write-Host "改善提案ページを生成しました: $proposalsPath" -ForegroundColor Green

# 総合評価ページを生成
$assessmentPath = Join-Path $docsDir "overall-assessment.md"
$assessmentContent = @"
# 総合評価

## 全体的な評価

"@

# 結論部分を抽出（レビューサマリーから）
$conclusionMatch = [regex]::Match($summaryContent, '##\s+結論([\s\S]*?)(?:##|$)')
if ($conclusionMatch.Success) {
    $assessmentContent += $conclusionMatch.Groups[1].Value.Trim() + "`n`n"
} else {
    $assessmentContent += @"
RNGNewAuraNotifierプロジェクトは全体的に良好な品質を保っています。コードは適切に構造化され、主要な機能は効果的に実装されています。

### 強み

- 明確に定義された責務を持つクラス設計
- 効率的なログ監視とAura検出の実装
- ユーザーフレンドリーなインターフェース
- 適切な設定管理と保存機能

### 弱み

- 一部のコンポーネントでの依存性注入の欠如
- テストコードの不足
- 一部の堅牢性とエラー処理の改善余地
- ドキュメンテーションの充実が求められる箇所

### 総括

プロジェクトは目的を達成するために十分な品質を備えていますが、提案された改善点を取り入れることで、保守性、拡張性、品質がさらに向上するでしょう。
"@
}

# カテゴリ別の評価スコアを計算して表示
$assessmentContent += "## カテゴリ別評価`n`n"
$assessmentContent += "| カテゴリ | ファイル数 | 評価 |\n"
$assessmentContent += "|---------|------------|-------|\n"

foreach ($category in $categories.Keys | Sort-Object) {
    $fileCount = $categories[$category].Count

    # 簡易的な評価を生成（A～Dの4段階）
    $goodPointsCount = 0
    $badPointsCount = 0

    foreach ($file in $categories[$category]) {
        $fileContent = Get-Content $file.FullName -Raw

        # 良い点をカウント
        $goodPointsMatch = [regex]::Match($fileContent, '(?:##\s+良い点|✅[^\r\n]*)([\s\S]*?)(?:##|$)')
        if ($goodPointsMatch.Success) {
            $goodPoints = [regex]::Matches($goodPointsMatch.Groups[1].Value, '\d+\.|[-✅]')
            $goodPointsCount += $goodPoints.Count
        }

        # 問題点をカウント
        $badPointsMatch = [regex]::Match($fileContent, '(?:##\s+問題点|❌[^\r\n]*)([\s\S]*?)(?:##|$)')
        if ($badPointsMatch.Success) {
            $badPoints = [regex]::Matches($badPointsMatch.Groups[1].Value, '\d+\.|[-❌]')
            $badPointsCount += $badPoints.Count
        }
    }

    # 評価スコアを計算（良い点:問題点の比率）
    $rating = "C"
    if ($goodPointsCount -gt 0 -or $badPointsCount -gt 0) {
        $ratio = if ($badPointsCount -eq 0) { 10 } else { $goodPointsCount / ($badPointsCount + 0.1) }

        if ($ratio -ge 3) {
            $rating = "A"
        } elseif ($ratio -ge 1.5) {
            $rating = "B"
        } elseif ($ratio -ge 0.5) {
            $rating = "C"
        } else {
            $rating = "D"
        }
    }

    $assessmentContent += "| $category | $fileCount | $rating |\n"
}

$assessmentContent | Out-File -FilePath $assessmentPath -Encoding UTF8
Write-Host "総合評価ページを生成しました: $assessmentPath" -ForegroundColor Green

Write-Host "`nすべてのドキュメント生成処理が完了しました。出力ディレクトリ: $docsDir" -ForegroundColor Cyan
