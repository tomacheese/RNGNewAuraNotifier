# RNGNewAuraNotifierプロジェクトのレビュー要約スクリプト
# 使用方法: .\SummarizeReviews.ps1

$reviewsDir = "s:\Git\CSharpProjects\RNGNewAuraNotifier\reviews"
$resultsDir = Join-Path $reviewsDir "results"
$outputDir = Join-Path $reviewsDir "summary"

# 出力ディレクトリがなければ作成
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory | Out-Null
    Write-Host "出力ディレクトリを作成しました: $outputDir" -ForegroundColor Green
}

# レビュー対象のファイル一覧
$reviewFiles = Get-ChildItem -Path $resultsDir -Recurse -File -Filter "*.md"
Write-Host "レビュー対象ファイル数: $($reviewFiles.Count)" -ForegroundColor Cyan

# ファイルパスをカテゴリに分類する関数
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

# レビューからキーポイントを抽出する関数
function Extract-ReviewKeyPoints {
    param (
        [string]$filePath
    )

    $content = Get-Content $filePath -Raw
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $relativePath = $filePath.Replace($resultsDir, "").TrimStart("\")
    $category = Get-FileCategory -filePath $filePath

    # 良い点を抽出
    $goodPoints = @()
    $goodPointsMatch = [regex]::Match($content, '(?:良い点|✅[^\r\n]*)([\s\S]*?)(?:##|$)')
    if ($goodPointsMatch.Success) {
        $goodPointsText = $goodPointsMatch.Groups[1].Value.Trim()
        $points = [regex]::Matches($goodPointsText, '\d+\.\s+[^`]*?([^\r\n]+)')
        foreach ($point in $points) {
            $goodPoints += $point.Groups[0].Value.Trim()
        }

        # 箇条書きの場合
        $bulletPoints = [regex]::Matches($goodPointsText, '[-✅]\s+([^\r\n]+)')
        foreach ($point in $bulletPoints) {
            $goodPoints += $point.Groups[0].Value.Trim()
        }
    }

    # 問題点を抽出
    $badPoints = @()
    $badPointsMatch = [regex]::Match($content, '(?:問題点|❌[^\r\n]*)([\s\S]*?)(?:##|$)')
    if ($badPointsMatch.Success) {
        $badPointsText = $badPointsMatch.Groups[1].Value.Trim()
        $points = [regex]::Matches($badPointsText, '\d+\.\s+[^`]*?([^\r\n]+)')
        foreach ($point in $points) {
            $badPoints += $point.Groups[0].Value.Trim()
        }

        # 箇条書きの場合
        $bulletPoints = [regex]::Matches($badPointsText, '[-❌]\s+([^\r\n]+)')
        foreach ($point in $bulletPoints) {
            $badPoints += $point.Groups[0].Value.Trim()
        }
    }

    # 改善案を抽出
    $suggestions = @()
    $suggestionsMatch = [regex]::Match($content, '(?:改善|提案)[^\r\n]*([\s\S]*?)(?:##|$)')
    if ($suggestionsMatch.Success) {
        $suggestionsText = $suggestionsMatch.Groups[1].Value.Trim()
        $points = [regex]::Matches($suggestionsText, '\d+\.\s+[^`]*?([^\r\n]+)')
        foreach ($point in $points) {
            $suggestions += $point.Groups[0].Value.Trim()
        }

        # 箇条書きの場合
        $bulletPoints = [regex]::Matches($suggestionsText, '[-•]\s+([^\r\n]+)')
        foreach ($point in $bulletPoints) {
            $suggestions += $point.Groups[0].Value.Trim()
        }
    }

    # 結果を返す
    return @{
        FileName = $fileName
        RelativePath = $relativePath
        Category = $category
        GoodPoints = $goodPoints
        BadPoints = $badPoints
        Suggestions = $suggestions
    }
}

# すべてのレビューファイルからキーポイントを抽出
$reviewKeyPoints = @()
foreach ($file in $reviewFiles) {
    $data = Extract-ReviewKeyPoints -filePath $file.FullName
    $reviewKeyPoints += $data
    Write-Host "キーポイント抽出完了: $($file.Name) - 良い点: $($data.GoodPoints.Count), 問題点: $($data.BadPoints.Count), 改善案: $($data.Suggestions.Count)" -ForegroundColor Yellow
}

# カテゴリ別のサマリーを生成
$categorySummaryPath = Join-Path $outputDir "category_summary.md"
$categorySummary = "# RNGNewAuraNotifier プロジェクト カテゴリ別レビューサマリー`n`n"

$categories = $reviewKeyPoints | Select-Object -ExpandProperty Category -Unique | Sort-Object
foreach ($category in $categories) {
    $categorySummary += "## $category`n`n"
    $categoryFiles = $reviewKeyPoints | Where-Object { $_.Category -eq $category }

    $categorySummary += "### レビュー対象ファイル`n`n"
    foreach ($file in $categoryFiles) {
        $categorySummary += "- $($file.RelativePath)`n"
    }

    $categorySummary += "`n### 良い点`n`n"
    $allGoodPoints = $categoryFiles | ForEach-Object { $_.GoodPoints } | Where-Object { $_ }
    if ($allGoodPoints) {
        foreach ($point in $allGoodPoints) {
            $categorySummary += "- $point`n"
        }
    } else {
        $categorySummary += "特に言及されていません。`n"
    }

    $categorySummary += "`n### 問題点`n`n"
    $allBadPoints = $categoryFiles | ForEach-Object { $_.BadPoints } | Where-Object { $_ }
    if ($allBadPoints) {
        foreach ($point in $allBadPoints) {
            $categorySummary += "- $point`n"
        }
    } else {
        $categorySummary += "特に言及されていません。`n"
    }

    $categorySummary += "`n### 改善提案`n`n"
    $allSuggestions = $categoryFiles | ForEach-Object { $_.Suggestions } | Where-Object { $_ }
    if ($allSuggestions) {
        foreach ($suggestion in $allSuggestions) {
            $categorySummary += "- $suggestion`n"
        }
    } else {
        $categorySummary += "特に言及されていません。`n"
    }

    $categorySummary += "`n---`n`n"
}

$categorySummary | Out-File -FilePath $categorySummaryPath -Encoding UTF8
Write-Host "カテゴリ別サマリーを出力しました: $categorySummaryPath" -ForegroundColor Green

# 良い点/問題点の一覧を生成
$pointsListPath = Join-Path $outputDir "review_points.md"
$pointsList = "# RNGNewAuraNotifier プロジェクト レビューポイント一覧`n`n"

$pointsList += "## 良い点一覧`n`n"
$allGoodPoints = $reviewKeyPoints | ForEach-Object {
    foreach ($point in $_.GoodPoints) {
        [PSCustomObject]@{
            Category = $_.Category
            File = $_.RelativePath
            Point = $point
        }
    }
} | Sort-Object -Property Category, File

foreach ($point in $allGoodPoints) {
    $pointsList += "- **[$($point.Category)]** $($point.Point) _($($point.File))_`n"
}

$pointsList += "`n## 問題点一覧`n`n"
$allBadPoints = $reviewKeyPoints | ForEach-Object {
    foreach ($point in $_.BadPoints) {
        [PSCustomObject]@{
            Category = $_.Category
            File = $_.RelativePath
            Point = $point
        }
    }
} | Sort-Object -Property Category, File

foreach ($point in $allBadPoints) {
    $pointsList += "- **[$($point.Category)]** $($point.Point) _($($point.File))_`n"
}

$pointsList += "`n## 改善提案一覧`n`n"
$allSuggestions = $reviewKeyPoints | ForEach-Object {
    foreach ($point in $_.Suggestions) {
        [PSCustomObject]@{
            Category = $_.Category
            File = $_.RelativePath
            Point = $point
        }
    }
} | Sort-Object -Property Category, File

foreach ($point in $allSuggestions) {
    $pointsList += "- **[$($point.Category)]** $($point.Point) _($($point.File))_`n"
}

$pointsList | Out-File -FilePath $pointsListPath -Encoding UTF8
Write-Host "レビューポイント一覧を出力しました: $pointsListPath" -ForegroundColor Green

# ファイルごとの点数評価（仮想的な計算）
$scoreAnalysisPath = Join-Path $outputDir "file_scores.csv"
$fileScores = $reviewKeyPoints | ForEach-Object {
    # 簡易的な点数計算（良い点1つにつき+1、問題点1つにつき-1、改善案は点数に影響なし）
    $score = $_.GoodPoints.Count - $_.BadPoints.Count
    # 最低点は0点とする
    if ($score -lt 0) { $score = 0 }
    # 最高点は10点とする
    $maxScore = 10
    $normalizedScore = [Math]::Min($score + 5, $maxScore) # 基本点5点に加減点

    [PSCustomObject]@{
        FilePath = $_.RelativePath
        Category = $_.Category
        GoodPoints = $_.GoodPoints.Count
        BadPoints = $_.BadPoints.Count
        Suggestions = $_.Suggestions.Count
        Score = $normalizedScore
    }
}

$fileScores | Export-Csv -Path $scoreAnalysisPath -NoTypeInformation -Encoding UTF8
Write-Host "ファイル評価スコアを出力しました: $scoreAnalysisPath" -ForegroundColor Green

# 改善提案の優先度付けレポート
$priorityReportPath = Join-Path $outputDir "improvement_priorities.md"
$priorityReport = "# RNGNewAuraNotifier プロジェクト 改善提案の優先度`n`n"

# カテゴリごとの改善提案数を集計
$categoryPriorities = $reviewKeyPoints |
    ForEach-Object { [PSCustomObject]@{ Category = $_.Category; SuggestionCount = $_.Suggestions.Count; BadPointCount = $_.BadPoints.Count } } |
    Group-Object -Property Category |
    ForEach-Object {
        [PSCustomObject]@{
            Category = $_.Name;
            SuggestionCount = ($_.Group | Measure-Object -Property SuggestionCount -Sum).Sum;
            BadPointCount = ($_.Group | Measure-Object -Property BadPointCount -Sum).Sum;
            PriorityScore = ($_.Group | Measure-Object -Property BadPointCount -Sum).Sum * 2 + ($_.Group | Measure-Object -Property SuggestionCount -Sum).Sum
        }
    } |
    Sort-Object -Property PriorityScore -Descending

$priorityReport += "## カテゴリ別優先度`n`n"
$priorityReport += "| カテゴリ | 問題点数 | 改善提案数 | 優先度スコア |\n"
$priorityReport += "|---------|----------|------------|---------------|\n"

foreach ($category in $categoryPriorities) {
    $priorityReport += "| $($category.Category) | $($category.BadPointCount) | $($category.SuggestionCount) | $($category.PriorityScore) |\n"
}

$priorityReport += "`n## 高優先度の改善提案`n`n"

# 問題点が多いカテゴリの改善提案を優先的に表示
$highPriorityCategories = $categoryPriorities | Where-Object { $_.PriorityScore -ge 5 } | Select-Object -ExpandProperty Category
foreach ($category in $highPriorityCategories) {
    $priorityReport += "### $category`n`n"

    $relevantFiles = $reviewKeyPoints | Where-Object { $_.Category -eq $category }
    foreach ($file in $relevantFiles) {
        if ($file.Suggestions.Count -gt 0) {
            $priorityReport += "**$($file.RelativePath)**:`n`n"
            foreach ($suggestion in $file.Suggestions) {
                $priorityReport += "- $suggestion`n"
            }
            $priorityReport += "`n"
        }
    }
}

$priorityReport | Out-File -FilePath $priorityReportPath -Encoding UTF8
Write-Host "改善提案の優先度レポートを出力しました: $priorityReportPath" -ForegroundColor Green

Write-Host "`nすべての要約処理が完了しました。出力ディレクトリ: $outputDir" -ForegroundColor Cyan
