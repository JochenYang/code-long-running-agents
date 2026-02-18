# Long-Running Agent Loop Executor
# Loop executor for calling Claude Code to execute tasks until all features pass: true

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

    # Read progress for context injection
    $progressContent = ""
    if (Test-Path (Join-Path $ProjectDir $PROGRESS_FILE)) {
        $progressContent = Get-Content (Join-Path $ProjectDir $PROGRESS_FILE) -Raw
    }

    # Build the task prompt
    $taskPrompt = @"
Please implement the following feature:

## Feature Description
$($nextFeature.description)

## Implementation Steps
$($nextFeature.steps | ForEach-Object { "$($_)" } | Out-String)

## Current Progress Context (System Context)
$progressContent

## Requirements
1. Start development server (if init.sh exists and not running)
2. Implement the feature above
3. After completion, update feature_list.json to set this feature's passes to true
4. Update claude-progress.txt to record progress
5. Commit to git (if git is initialized)

Note: Only mark passes: true after verifying the feature works correctly
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
        Write-Host "🛑 Stopping loop due to failure to prevent cascading errors." -ForegroundColor Red
        break
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
