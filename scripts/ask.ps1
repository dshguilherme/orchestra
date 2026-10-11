<#
.SYNOPSIS
  Send a question to an external model/agent runtime and save the answer.
.EXAMPLE
  ./ask.ps1 -List
  ./ask.ps1 -Adapter hermes -Question "..." -Out research/x/external/hermes.md
.NOTES
  Send the research QUESTION only. Never pipe workspace files, memory, or secrets.
#>
param(
  [string]$Adapter,
  [string]$Question,
  [string]$Out,
  [int]$TimeoutSec = 600,
  [switch]$List
)

function Find-Cmd($names) {
  foreach ($n in $names) { $c = Get-Command $n -ErrorAction SilentlyContinue; if ($c) { return $c.Source } }
  return $null
}

$adapters = [ordered]@{
  hermes   = Find-Cmd @('hermes')
  openclaw = Find-Cmd @('openclaw')
  gemini   = Find-Cmd @('gemini', 'antigravity-cli', 'antigravity')
}

if ($List) {
  foreach ($k in $adapters.Keys) {
    $state = if ($adapters[$k]) { "available  ($($adapters[$k]))" } else { 'NOT FOUND' }
    "{0,-9} {1}" -f $k, $state
  }
  return
}

if (-not $Adapter -or -not $Question) { Write-Error 'Need -Adapter and -Question (or -List).'; exit 2 }
$exe = $adapters[$Adapter]
if (-not $exe) { Write-Error "Adapter '$Adapter' not available."; exit 3 }

$prompt = @"
Research question (answer independently; cite primary sources with URLs; quote key passages;
state clearly what you could not verify; do not guess at citations):

$Question
"@

# Long prompts go through a file to avoid quoting problems.
$tmp = New-TemporaryFile
Set-Content -Path $tmp -Value $prompt -Encoding utf8

$job = Start-Job -ScriptBlock {
  param($Adapter, $exe, $tmp)
  $p = Get-Content -Raw $tmp
  switch ($Adapter) {
    'hermes'   { & $exe -z $p }
    'openclaw' { & $exe agent --local --message-file $tmp }
    'gemini'   { & $exe -p $p }   # adjust if your Gemini/Antigravity CLI uses a different headless flag
  }
} -ArgumentList $Adapter, $exe, $tmp.FullName

if (Wait-Job $job -Timeout $TimeoutSec) {
  $text = (Receive-Job $job) -join "`n"
} else {
  Stop-Job $job; $text = "[TIMEOUT after $TimeoutSec s]"
}
Remove-Job $job -Force; Remove-Item $tmp -Force

if ($Out) {
  New-Item -ItemType Directory -Force (Split-Path $Out) | Out-Null
  Set-Content -Path $Out -Value "<!-- adapter: $Adapter, $(Get-Date -Format s) -->`n$text" -Encoding utf8
  "Saved to $Out"
} else { $text }
