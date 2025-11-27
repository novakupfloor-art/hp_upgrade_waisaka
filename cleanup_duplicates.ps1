# PowerShell script to remove duplicate old files and folders

# Remove old nested folders with their files
$foldersToRemove = @(
    "lib\screens\admin",
    "lib\screens\auth",
    "lib\screens\dashboard-panel-users",
    "lib\screens\property",
    "lib\screens\profile",
    "lib\screens\staff"
)

foreach ($folder in $foldersToRemove) {
    if (Test-Path $folder) {
        Remove-Item -Path $folder -Recurse -Force
        Write-Host "Removed folder: $folder" -ForegroundColor Green
    }
    else {
        Write-Host "Folder not found: $folder" -ForegroundColor Yellow
    }
}

Write-Host "`nCleanup completed! Old nested folders removed." -ForegroundColor Green
Write-Host "Only flat structure files remain in lib\screens\" -ForegroundColor Cyan
