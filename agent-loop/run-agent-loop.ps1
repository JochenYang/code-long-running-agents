# Long-Running Agent Loop Executor
# 用于循环调用 Claude Code 执行任务，直到所有 feature passes: true

param(
    [string]$ProjectDir = ".",
    [int]$MaxIterations = 100,
    [switch]$Verbose
)

$FEATURES_FILE = "feature_list.json"
$PROGRESS_FILE = "claude-progress.txt"

function Get-NextFeature {
    param([string]$Dir)

    $featuresPath = Join-Path $Dir $FEATURES_FILE
    if (-not (Test-Path $featuresPath)) {
        Write-Host "❌ feature_list.json not found in $Dir" -ForegroundColor Red
        return $null
    }

    $content = Get-Content $featuresPath -Raw | ConvertFrom-Json

    foreach ($feature in $content.features) {
        if ($feature.passes -eq $false) {
            return $feature
        }
    }

    return $null
}

function Get-AllFeaturesStatus {
    param([string]$Dir)

    $featuresPath = Join-Path $Dir $FEATURES_FILE
    if (-not (Test-Path $featuresPath)) {
        return @{ total = 0; completed = 0 }
    }

    $content = Get-Content $featuresPath -Raw | ConvertFrom-Json
    $total = $content.features.Count
    $completed = ($content.features | Where-Object { $_.passes -eq $true }).Count

    return @{ total = $total; completed = $completed }
}

function Update-Progress {
    param([string]$Dir, [string]$FeatureId, [string]$Status)

    $progressPath = Join-Path $Dir $PROGRESS_FILE
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $entry = "## $timestamp - Feature $FeatureId: $Status`n"

    if (Test-Path $progressPath) {
        Add-Content $progressPath $entry
    } else {
        Set-Content $progressPath "# Claude Progress`n`n$entry"
    }
}

function Test-AllFeaturesComplete {
    param([string]$Dir)

    $status = Get-AllFeaturesStatus -Dir $Dir
    return $status.completed -eq $status.total
}

# Main loop
Write-Host "🚀 Starting Long-Running Agent Loop..." -ForegroundColor Cyan
Write-Host "Project: $ProjectDir" -ForegroundColor Gray
Write-Host ""

$iteration = 0

while ($iteration -lt $MaxIterations) {
    $iteration++

    # Check if all features are complete
    if (Test-AllFeaturesComplete -Dir $ProjectDir) {
        Write-Host "✅ All features completed!" -ForegroundColor Green
        break
    }

    # Get status
    $status = Get-AllFeaturesStatus -Dir $ProjectDir

    # Get next feature
    $nextFeature = Get-NextFeature -Dir $ProjectDir

    if ($null -eq $nextFeature) {
        Write-Host "✅ All features marked as complete!" -ForegroundColor Green
        break
    }

    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "📋 Iteration $iteration / $MaxIterations" -ForegroundColor Yellow
    Write-Host "📊 Progress: $($status.completed) / $($status.total) completed" -ForegroundColor Cyan
    Write-Host "🎯 Next Feature: $($nextFeature.description)" -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Yellow

    # Build the task prompt
    $taskPrompt = @"
请实现以下功能：

## 功能描述
$($nextFeature.description)

## 实现步骤
$($nextFeature.steps | ForEach-Object { "$($_)" } | Out-String)

## 要求
1. 先读取 claude-progress.txt 和 feature_list.json 了解当前状态
2. 启动开发服务器 (如果有 init.sh)
3. 实现上述功能
4. 完成后更新 feature_list.json 中该功能的 passes 为 true
5. 更新 claude-progress.txt 记录进度
6. 提交 git (如果已初始化 git)

注意：必须验证功能正常工作后才能标记为 passes: true
"@

    # Call Claude Code with the task (non-interactive mode)
    Write-Host "`n⏳ Waiting for Claude Code to complete..." -ForegroundColor Gray

    # Use stdin to pass the prompt to Claude Code
    $result = $taskPrompt | claude -p 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Iteration completed" -ForegroundColor Green
        Update-Progress -Dir $ProjectDir -FeatureId $nextFeature.id -Status "Completed"
    } else {
        Write-Host "❌ Iteration failed with exit code $LASTEXITCODE" -ForegroundColor Red
        Update-Progress -Dir $ProjectDir -FeatureId $nextFeature.id -Status "Failed"
    }

    if ($Verbose) {
        Write-Host "`n--- Claude Output ---" -ForegroundColor Gray
        Write-Host $result
        Write-Host "--- End Output ---`n" -ForegroundColor Gray
    }

    Write-Host ""
}

Write-Host ""
Write-Host "🏁 Loop finished after $iteration iterations" -ForegroundColor Cyan

# Final status
$finalStatus = Get-AllFeaturesStatus -Dir $ProjectDir
Write-Host "📊 Final Progress: $($finalStatus.completed) / $($finalStatus.total) features completed" -ForegroundColor $(if ($finalStatus.completed -eq $finalStatus.total) { "Green" } else { "Yellow" })
