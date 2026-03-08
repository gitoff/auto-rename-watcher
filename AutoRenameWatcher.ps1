# ================================
# Auto-Rename Watcher (Cinemaflight Edition)
# ================================

$WatchPath = "E:\AutoRenameImages"
$LogFile   = "$WatchPath\rename_log.txt"

# Image extensions allowed
$ImageExts = @(".jpg", ".jpeg", ".png", ".gif", ".webp", ".tif", ".tiff", ".bmp")

# Create log function
function Log($msg) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $LogFile -Value "[$timestamp] $msg"
}

# Ensure log exists
if (!(Test-Path $LogFile)) { New-Item -Path $LogFile -ItemType File | Out-Null }

# Setup watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $WatchPath
$watcher.Filter = "*.*"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

Log "Watcher started on $WatchPath"

Register-ObjectEvent $watcher Created -Action {

    try {
        $file = $Event.SourceEventArgs.FullPath
        $ext  = [System.IO.Path]::GetExtension($file).ToLower()

        # Ignore non-images
        if ($ImageExts -notcontains $ext) {
            Log "Ignored non-image file: $file"
            return
        }

        # Wait until file is fully written
        for ($i=1; $i -le 20; $i++) {
            try {
                $stream = [System.IO.File]::Open($file, 'Open', 'ReadWrite', 'None')
                if ($stream) { $stream.Close(); break }
            } catch {
                Start-Sleep -Milliseconds 200
            }
        }

        # Build timestamp
        $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
        $baseName  = "download_$timestamp"
        $newName   = "$baseName$ext"
        $newPath   = Join-Path (Split-Path $file) $newName

        # Collision handling
        $counter = 1
        while (Test-Path $newPath) {
            $newName = "${baseName}_$counter$ext"
            $newPath = Join-Path (Split-Path $file) $newName
            $counter++
        }

        # Rename
        Rename-Item -Path $file -NewName $newName -ErrorAction Stop
        Log "Renamed: $file → $newName"
    }
    catch {
        Log "ERROR processing $file : $_"
    }
}

# Keep script alive
while ($true) { Start-Sleep -Seconds 1 }