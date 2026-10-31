# make_p3_zip.ps1 — run from the project root.
param(
  [ValidateSet('Lean','Full')][string]$Profile = 'Lean',
  [string]$ChangedSince = ''          # e.g. HEAD~1, main, a tag, a commit hash
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path .\pubspec.yaml)) { throw 'Run this from the folder that contains pubspec.yaml' }

$root    = (Get-Location).Path
$stamp   = Get-Date -Format 'yyyyMMdd-HHmm'
$mode    = if ($ChangedSince) { 'delta' } else { $Profile.ToLower() }
$staging = Join-Path $env:TEMP "family_hub_p3_$stamp"
$zip     = Join-Path $root "family_hub_p3_${mode}_$stamp.zip"
if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }
New-Item -ItemType Directory -Path $staging | Out-Null

# Never copied, in any mode.
$excludeDirs  = @('.git','.dart_tool','build','.idea','.vscode','node_modules','.gradle','Pods','coverage','.fvm')
$excludeFiles = @('google-services.json','GoogleService-Info.plist','key.properties','*.jks','*.keystore',
                  '.env','.env.*','*.log','*.apk','*.aab','*.iml','local.properties','service-account*.json')

# Lean profile: folders skipped (relative to the project root).
$leanSkip = @(
  'assets\fonts',
  'ios',
  'lib\features\bazar\advances',
  'lib\features\bazar\budgets',
  'lib\features\bazar\contributions',
  'lib\features\bazar\expenses',
  'lib\features\bazar\fund',
  'lib\features\bazar\import',
  'lib\features\bazar\items_categories',
  'lib\features\bazar\presentation',
  'lib\features\bazar\reports',
  'test\features\bazar'
)
# Lean profile: root markdown files skipped.
$leanSkipRootFiles = @('ROADMAP.md','PHASE1_HARDENING_ROADMAP.md','PHASE2_BAZAR_ROADMAP.md','UPLOAD_CODEBASE_TO_CLAUDE.md')
# Lean profile: the only Android files copied.
$leanAndroidFiles = @('android\app\src\main\AndroidManifest.xml','android\app\build.gradle','android\app\build.gradle.kts',
                      'android\build.gradle','android\build.gradle.kts','android\settings.gradle','android\settings.gradle.kts',
                      'android\gradle.properties')
# Root files always copied when present.
$rootFiles = @('pubspec.yaml','pubspec.lock','analysis_options.yaml','l10n.yaml','dart_test.yaml','firebase.json',
               '.firebaserc','.gitignore','.gitattributes','CLAUDE.md','AGENTS.md','PROGRESS.md','README.md')

function Copy-Tree($rel, $extraSkip) {
  $src = Join-Path $root $rel
  if (-not (Test-Path $src)) { return }
  $xd = @($excludeDirs) + @($extraSkip | ForEach-Object { Join-Path $root $_ })
  robocopy $src (Join-Path $staging $rel) /E /XD $xd /XF $excludeFiles /NFL /NDL /NJH /NJS /NP | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "robocopy failed for $rel (exit $LASTEXITCODE)" }
}

$skipped = @()
if ($ChangedSince) {
  # DELTA: only files changed since the given git ref, plus the always-needed root files.
  $changed  = @(git diff --name-only --diff-filter=ACMR $ChangedSince)
  $changed += @(git ls-files --others --exclude-standard)
  foreach ($f in ($changed | Sort-Object -Unique)) {
    $p = Join-Path $root $f
    if (-not (Test-Path $p -PathType Leaf)) { continue }
    $name = Split-Path $f -Leaf
    if ($excludeFiles | Where-Object { $name -like $_ }) { continue }
    if ($f -match '(^|[\\/])(node_modules|build|\.dart_tool|\.git)[\\/]') { continue }
    $dest = Join-Path $staging $f
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item $p $dest -Force
  }
  foreach ($f in @('CLAUDE.md','PROGRESS.md','pubspec.yaml')) {
    $p = Join-Path $root $f
    if (Test-Path $p) { Copy-Item $p (Join-Path $staging $f) -Force }
  }
} else {
  $folders = @('lib','test','firebase','tools','docs','.github')
  if ($Profile -eq 'Full') { $folders += @('android','assets','integration_test') }
  $extra = if ($Profile -eq 'Lean') { $leanSkip } else { @() }
  foreach ($f in $folders) { Copy-Tree $f $extra }
  foreach ($f in $rootFiles) {
    $p = Join-Path $root $f
    if (Test-Path $p) { Copy-Item $p (Join-Path $staging $f) -Force }
  }
  if ($Profile -eq 'Full') {
    Get-ChildItem $root -Filter *.md -File | ForEach-Object { Copy-Item $_.FullName (Join-Path $staging $_.Name) -Force }
  } else {
    Get-ChildItem $root -Filter *.md -File | Where-Object { $leanSkipRootFiles -notcontains $_.Name } |
      ForEach-Object { Copy-Item $_.FullName (Join-Path $staging $_.Name) -Force }
    foreach ($f in $leanAndroidFiles) {
      $p = Join-Path $root $f
      if (Test-Path $p) {
        $dest = Join-Path $staging $f
        New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
        Copy-Item $p $dest -Force
      }
    }
    $skipped = $leanSkip + $leanSkipRootFiles + @('android (everything except manifest + gradle files)')
  }
  # Golden images are never needed by Claude.
  Get-ChildItem $staging -Recurse -Directory -Filter goldens -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force
}

# Safety net: remove any secret that slipped in.
Get-ChildItem $staging -Recurse -Force -File | Where-Object {
  $_.Name -in @('google-services.json','GoogleService-Info.plist','key.properties') -or
  $_.Extension -in @('.jks','.keystore')
} | Remove-Item -Force

# Manifest so Claude knows what it is looking at.
$head = ''; $dirty = ''
try { $head = (git rev-parse --short HEAD) 2>$null; $dirty = (git status --porcelain | Measure-Object).Count } catch {}
@(
  "Family Hub upload manifest",
  "Created : $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
  "Mode    : $mode" + $(if ($ChangedSince) { " (changed since $ChangedSince)" } else { '' }),
  "Git     : HEAD $head, $dirty uncommitted change(s)",
  "Skipped : " + $(if ($skipped.Count) { ($skipped -join ', ') } else { '(nothing beyond the standard excludes)' }),
  "Note    : files not listed here are simply not in this zip; ask me for them instead of guessing."
) | Set-Content -Encoding UTF8 (Join-Path $staging 'UPLOAD_MANIFEST.txt')

# Create and validate ZIP using .NET
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (Test-Path $zip) {
    Remove-Item $zip -Force
}

try {
    # Create ZIP while preserving the complete folder structure.
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $staging,
        $zip,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false
    )

    # Verify archive integrity.
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zip)

    try {
        $entryCount = $archive.Entries.Count

        if ($entryCount -eq 0) {
            throw "ZIP archive is empty!"
        }

        $totalSize = ($archive.Entries |
            Measure-Object -Property Length -Sum).Sum

        if ($totalSize -eq 0) {
            throw "ZIP archive contains no file content!"
        }

        Write-Host ""
        Write-Host "ZIP VALIDATION SUCCESSFUL" -ForegroundColor Green
        Write-Host "Files       : $entryCount"
        Write-Host "Content     : $([math]::Round($totalSize / 1MB, 2)) MB"
        Write-Host "ZIP Size    : $([math]::Round((Get-Item $zip).Length / 1MB, 2)) MB"
        Write-Host "Location    : $zip"
    }
    finally {
        $archive.Dispose()
    }

    # Remove staging ONLY after successful validation.
    Remove-Item $staging -Recurse -Force

}
catch {
    Write-Host ""
    Write-Host "ZIP CREATION / VALIDATION FAILED!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "Staging directory preserved: $staging" -ForegroundColor Yellow

    throw
}