# RNGNewAuraNotifierプロジェクトのレビュー結果抽出スクリプト
# 使用方法: .\ExtractReviewInfo.ps1

$reviewsDir = "s:\Git\CSharpProjects\RNGNewAuraNotifier\reviews"
$resultsDir = Join-Path $reviewsDir "results"
$outputDir = Join-Path $reviewsDir "output"

# 出力ディレクトリがなければ作成
if (-not (Test-Path $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory | Out-Null
    Write-Host "出力ディレクトリを作成しました: $outputDir" -ForegroundColor Green
}

# レビュー対象のファイル一覧
$reviewFiles = Get-ChildItem -Path $resultsDir -Recurse -File -Filter "*.md"
Write-Host "レビュー対象ファイル数: $($reviewFiles.Count)" -ForegroundColor Cyan

# レビューのセクション情報を抽出する関数
function Extract-ReviewSections {
    param (
        [string]$filePath
    )

    $content = Get-Content $filePath -Raw
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $relativePath = $filePath.Replace($resultsDir, "").TrimStart("\")

    # セクションを抽出
    $sections = [System.Collections.ArrayList]@()
    $matches = [regex]::Matches($content, '##\s+([^\r\n]+)')

    foreach ($match in $matches) {
        $sectionName = $match.Groups[1].Value.Trim()
        $sections.Add($sectionName) | Out-Null
    }

    # 概要を抽出（最初の## セクションの前のテキスト）
    $overview = ""
    if ($matches.Count -gt 0) {
        $firstSectionIndex = $content.IndexOf("## " + $matches[0].Groups[1].Value)
        if ($firstSectionIndex -gt 0) {
            $headerEndIndex = $content.IndexOf("`n", $content.IndexOf("# "))
            if ($headerEndIndex -gt 0) {
                $overview = $content.Substring($headerEndIndex, $firstSectionIndex - $headerEndIndex).Trim()
            }
        }
    }

    # 問題点と改善提案を抽出
    $issuesAndSuggestions = ""
    foreach ($section in $sections) {
        if ($section -match "問題点|改善|提案") {
            $sectionStart = $content.IndexOf("## $section")
            $sectionEnd = $content.Length

            # 次のセクションがあれば、そこまでの範囲を取得
            $nextSectionIndex = $sections.IndexOf($section) + 1
            if ($nextSectionIndex -lt $sections.Count) {
                $nextSection = $sections[$nextSectionIndex]
                $sectionEnd = $content.IndexOf("## $nextSection")
            }

            if ($sectionStart -ge 0 -and $sectionEnd -gt $sectionStart) {
                $sectionContent = $content.Substring($sectionStart, $sectionEnd - $sectionStart).Trim()
                $issuesAndSuggestions += "`n$sectionContent`n"
            }
        }
    }

    # 結果を返す
    return @{
        FileName = $fileName
        RelativePath = $relativePath
        Overview = $overview
        Sections = $sections
        IssuesAndSuggestions = $issuesAndSuggestions
    }
}

# すべてのレビューファイルからセクション情報を抽出
$reviewData = @()
foreach ($file in $reviewFiles) {
    $data = Extract-ReviewSections -filePath $file.FullName
    $reviewData += $data
    Write-Host "抽出完了: $($file.Name) - セクション数: $($data.Sections.Count)" -ForegroundColor Yellow
}

# レビューサマリー情報
$summaryPath = Join-Path $reviewsDir "review-summary.md"
$summaryContent = ""
if (Test-Path $summaryPath) {
    $summaryContent = Get-Content $summaryPath -Raw
    Write-Host "レビューサマリーを読み込みました" -ForegroundColor Green
}

# ファイルごとのセクション情報をCSVに出力
$sectionAnalysisPath = Join-Path $outputDir "section_analysis.csv"
$reviewData | Select-Object FileName, RelativePath, @{Name="SectionCount"; Expression={$_.Sections.Count}}, @{Name="Sections"; Expression={$_.Sections -join ", "}} |
    Export-Csv -Path $sectionAnalysisPath -NoTypeInformation -Encoding UTF8
Write-Host "セクション分析をCSVに出力しました: $sectionAnalysisPath" -ForegroundColor Green

# 問題点と改善提案をテキストファイルに出力
$issuesPath = Join-Path $outputDir "issues_and_suggestions.md"
$issuesContent = "# RNGNewAuraNotifier プロジェクトの問題点と改善提案`n`n"
foreach ($data in $reviewData) {
    if (-not [string]::IsNullOrWhiteSpace($data.IssuesAndSuggestions)) {
        $issuesContent += "## $($data.RelativePath)`n`n$($data.IssuesAndSuggestions)`n`n---`n`n"
    }
}
$issuesContent | Out-File -FilePath $issuesPath -Encoding UTF8
Write-Host "問題点と改善提案を出力しました: $issuesPath" -ForegroundColor Green

# レビュー概要をテキストファイルに出力
$overviewPath = Join-Path $outputDir "file_overviews.md"
$overviewContent = "# RNGNewAuraNotifier プロジェクトのファイル概要`n`n"
foreach ($data in $reviewData) {
    if (-not [string]::IsNullOrWhiteSpace($data.Overview)) {
        $overviewContent += "## $($data.RelativePath)`n`n$($data.Overview)`n`n---`n`n"
    }
}
$overviewContent | Out-File -FilePath $overviewPath -Encoding UTF8
Write-Host "ファイル概要を出力しました: $overviewPath" -ForegroundColor Green

# レビューサマリーの主要セクションを抽出
$summaryPath = Join-Path $outputDir "summary_extract.md"
$summaryExtract = "# RNGNewAuraNotifier レビューサマリー抜粋`n`n"

# サマリーから主要セクションを抽出
$sectionMatches = [regex]::Matches($summaryContent, '##\s+([^\r\n]+)')
foreach ($match in $sectionMatches) {
    $sectionName = $match.Groups[1].Value.Trim()
    $sectionStart = $summaryContent.IndexOf("## $sectionName")
    $sectionEnd = $summaryContent.Length

    # 次のセクションがあれば、そこまでの範囲を取得
    for ($i = 0; $i -lt $sectionMatches.Count; $i++) {
        if ($sectionMatches[$i].Groups[1].Value.Trim() -eq $sectionName) {
            if ($i + 1 -lt $sectionMatches.Count) {
                $nextSection = $sectionMatches[$i + 1].Groups[1].Value.Trim()
                $sectionEnd = $summaryContent.IndexOf("## $nextSection")
                break
            }
        }
    }

    if ($sectionStart -ge 0 -and $sectionEnd -gt $sectionStart) {
        $sectionContent = $summaryContent.Substring($sectionStart, $sectionEnd - $sectionStart).Trim()
        $summaryExtract += "$sectionContent`n`n---`n`n"
    }
}

$summaryExtract | Out-File -FilePath $summaryPath -Encoding UTF8
Write-Host "レビューサマリー抜粋を出力しました: $summaryPath" -ForegroundColor Green

# 統計情報を生成
$statsPath = Join-Path $outputDir "review_statistics.txt"
$stats = @"
# RNGNewAuraNotifier プロジェクトレビュー統計

## 基本情報
- レビューファイル総数: $($reviewFiles.Count)
- レビュー日: $(Get-Date -Format "yyyy年MM月dd日")

## セクション分析
- セクションが最も多いファイル: $($reviewData | Sort-Object -Property {$_.Sections.Count} -Descending | Select-Object -First 1 -ExpandProperty FileName) ($($reviewData | Sort-Object -Property {$_.Sections.Count} -Descending | Select-Object -First 1 -ExpandProperty Sections.Count)セクション)
- セクションが最も少ないファイル: $($reviewData | Where-Object {$_.Sections.Count -gt 0} | Sort-Object -Property {$_.Sections.Count} | Select-Object -First 1 -ExpandProperty FileName) ($($reviewData | Where-Object {$_.Sections.Count -gt 0} | Sort-Object -Property {$_.Sections.Count} | Select-Object -First 1 -ExpandProperty Sections.Count)セクション)
- 平均セクション数: $([math]::Round($reviewData.Sections.Count | Measure-Object -Average | Select-Object -ExpandProperty Average, 1))

## セクション種類の分布
$($reviewData.Sections | Group-Object | Sort-Object -Property Count -Descending | ForEach-Object { "- $($_.Name): $($_.Count)回" })

## ファイルタイプ別レビュー数
$($reviewData.FileName | ForEach-Object { [System.IO.Path]::GetExtension($_) } | Group-Object | Sort-Object -Property Count -Descending | ForEach-Object { "- $($_.Name): $($_.Count)ファイル" })
"@

$stats | Out-File -FilePath $statsPath -Encoding UTF8
Write-Host "レビュー統計情報を出力しました: $statsPath" -ForegroundColor Green

Write-Host "`nすべての抽出処理が完了しました。出力ディレクトリ: $outputDir" -ForegroundColor Cyan
