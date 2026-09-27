# Play a pre-generated voice clip (Microsoft neural voice via edge-tts) from this folder.
# Used by the Stop hook (done.mp3) and the PermissionRequest hook (-Clip permission.mp3).
param([string]$Clip = 'done.mp3')
Add-Type -AssemblyName PresentationCore
$player = New-Object System.Windows.Media.MediaPlayer
$player.Open([Uri](Join-Path $PSScriptRoot $Clip))
# Wait for the file to load so the real clip length is known (max ~2s)
for ($i = 0; $i -lt 40 -and -not $player.NaturalDuration.HasTimeSpan; $i++) { Start-Sleep -Milliseconds 50 }
$ms = if ($player.NaturalDuration.HasTimeSpan) { $player.NaturalDuration.TimeSpan.TotalMilliseconds } else { 2500 }
$player.Play()
Start-Sleep -Milliseconds ([int]$ms + 300)
$player.Close()
