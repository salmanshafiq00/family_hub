#requires -Version 5.1
<#
.SYNOPSIS
  Deletes Family Hub test data (chores, swaps, notifications, audit) for ONE family.

.DESCRIPTION
  Runs `firebase firestore:delete` for the family subcollections that hold test
  data. Nothing is deleted from the app itself: Firestore documents are removed
  with the Firebase Admin path, so rules do not apply.

  Collections removed under families/{FamilyId}:
    choreTemplates
    choreOccurrences        (recursive: also events/ and comments/)
    swapRequests
    dutyGroups
    memberAvailability
    notificationInbox
    activity
    auditLogs
    memberStats             (derived from occurrences)
    memberStatsPublic       (derived from occurrences)

  Documents removed under families/{FamilyId}:
    settings/choreGeneration   (generation marker; without this the app will
                                not regenerate the deleted occurrences)

  Optional (pass -UserId):
    users/{UserId}/devices     (push tokens; the app registers again on launch)

  The family document, members, settings (other than the marker), expenses and
  all other Bazar data are NOT touched.

.PARAMETER FamilyId
  The family document id, e.g. the id under families/{familyId} in Firestore.
  If omitted, the script prompts for it.

.PARAMETER ProjectId
  Firebase project id. Defaults to familyhub-app-ai (the project used by BOTH
  the dev and prod flavors in this repo).
  With -Emulator and no explicit value, defaults to demo-family-hub.

.PARAMETER UserId
  Optional. Also deletes users/{uid}/devices (push tokens) for this user.

.PARAMETER Emulator
  Delete from the local Firestore emulator (FIRESTORE_EMULATOR_HOST=127.0.0.1:8080).
  Note: the emulator keeps data in memory, so stopping it already wipes
  everything; use this only to clear one family while it runs.

.PARAMETER DryRun
  Print the commands without running them.

.PARAMETER Force
  Skip the interactive confirmation.

.EXAMPLE
  .\tools\clear_test_data.ps1 -FamilyId "abc123" -DryRun

.EXAMPLE
  .\tools\clear_test_data.ps1 -FamilyId "abc123"

.EXAMPLE
  .\tools\clear_test_data.ps1 -FamilyId "abc123" -UserId "uid123" -Force

.EXAMPLE
  .\tools\clear_test_data.ps1 -FamilyId "abc123" -Emulator

.NOTES
  Requires: npm install -g firebase-tools, and `firebase login` for a real project.
  Both the dev and prod Android flavors in this repo use the same Firebase
  project (familyhub-app-ai), so this deletes from the real database.
  Equivalent single command for one collection:
    firebase firestore:delete --project familyhub-app-ai --recursive --force "families/abc123/choreOccurrences"
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$FamilyId,

  [string]$ProjectId = 'familyhub-app-ai',

  [string]$UserId,

  [switch]$Emulator,

  [switch]$DryRun,

  [switch]$Force
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($FamilyId)) {
  Write-Host 'Find it in the Firebase Console: Firestore Database > families > <document id>.'
  $FamilyId = Read-Host 'Family id (the id under families/{familyId})'
}

if ([string]::IsNullOrWhiteSpace($FamilyId)) {
  throw 'FamilyId is required (the id under families/{familyId}).'
}

if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
  throw 'firebase CLI not found. Install it with: npm install -g firebase-tools'
}

# Collections removed with --recursive (subcollections included).
$familyCollections = @(
  'choreTemplates',
  'choreOccurrences',      # also removes events/ and comments/
  'swapRequests',
  'dutyGroups',
  'memberAvailability',
  'notificationInbox',     # in-app notifications
  'activity',
  'auditLogs',
  'memberStats',           # derived from occurrences
  'memberStatsPublic'      # derived from occurrences
)

# Single documents removed without --recursive.
$familyDocuments = @(
  'settings/choreGeneration'  # marker; reset so chores generate again
)

$familyPath = "families/$FamilyId"

function Invoke-FirestoreDelete {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [switch]$Recursive
  )

  $cliArgs = @('firestore:delete', '--project', $ProjectId, '--force')
  if ($Recursive) { $cliArgs += '--recursive' }
  $cliArgs += $Path

  Write-Host ("  firebase " + ($cliArgs -join ' '))
  if ($DryRun) { return }

  & firebase @cliArgs
  if ($LASTEXITCODE -ne 0) {
    throw "firebase firestore:delete failed for '$Path' (exit code $LASTEXITCODE)."
  }
}

$previousEmulatorHost = $env:FIRESTORE_EMULATOR_HOST
$usingEmulator = [bool]$Emulator

if ($usingEmulator) {
  if (-not $PSBoundParameters.ContainsKey('ProjectId')) {
    $ProjectId = 'demo-family-hub'
  }
  $env:FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080'
  Write-Host 'Mode: local emulator (127.0.0.1:8080)'
} else {
  Write-Host "Mode: project '$ProjectId'"
}

Write-Host "Family: $familyPath"
Write-Host ''

try {
  if (-not $Force -and -not $DryRun) {
    Write-Host 'This permanently deletes the test data listed below.'
    $answer = Read-Host "Type 'yes' to continue"
    if ($answer -ne 'yes') {
      Write-Host 'Cancelled. Nothing was deleted.'
      return
    }
    Write-Host ''
  }

  Write-Host 'Collections (recursive):'
  foreach ($collection in $familyCollections) {
    Invoke-FirestoreDelete -Path "$familyPath/$collection" -Recursive
  }

  Write-Host ''
  Write-Host 'Documents:'
  foreach ($document in $familyDocuments) {
    Invoke-FirestoreDelete -Path "$familyPath/$document"
  }

  if (-not [string]::IsNullOrWhiteSpace($UserId)) {
    Write-Host ''
    Write-Host 'User push tokens (recursive):'
    Invoke-FirestoreDelete -Path "users/$UserId/devices" -Recursive
  }

  Write-Host ''
  if ($DryRun) {
    Write-Host 'Dry run complete. Nothing was deleted.'
  } else {
    Write-Host 'Done. Clear the app data on the phone (Settings > Apps > Family Hub > Storage > Clear data)'
    Write-Host 'so the cached documents disappear, then sign in again.'
  }
}
finally {
  if ($usingEmulator) {
    if ($null -eq $previousEmulatorHost) {
      Remove-Item Env:\FIRESTORE_EMULATOR_HOST -ErrorAction SilentlyContinue
    } else {
      $env:FIRESTORE_EMULATOR_HOST = $previousEmulatorHost
    }
  }
}
