$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "E:\AutoRename"
$watcher.Filter = "*.*"
$watcher.EnableRaisingEvents = $true
$watcher.IncludeSubdirectories = $false

Register-ObjectEvent $watcher Created -Action {
    Start-Sleep -Milliseconds 300

    $file = $Event.SourceEventArgs.FullPath
    $ext = [System.IO.Path]::GetExtension($file)

    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $newName = "download_$timestamp$ext"

    $newPath = Join-Path (Split-Path $file) $newName

    Rename-Item -Path $file -NewName $newName -ErrorAction SilentlyContinue
}
while ($true) { Start-Sleep -Seconds 1 }

