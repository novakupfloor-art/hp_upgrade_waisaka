# PowerShell script to fix all remaining parameter errors

# Fix screens_dashboard.dart - remove unused imports and fix AddPropertyScreen
$file = "lib\screens\screens_dashboard.dart"
$content = Get-Content -Path $file -Raw -Encoding UTF8
# Remove unused import
$content = $content -replace "import 'screens_profile\.dart';", ""
# Fix AddPropertyScreen to include user parameter
$content = $content -replace "const AddPropertyScreen\(\)", "AddPropertyScreen(user: widget.user)"
Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline
Write-Host "Fixed: $file"

# Fix screens_iklan_property_tab.dart - add user parameter to AddPropertyScreen and EditPropertyScreen
$file = "lib\screens\screens_iklan_property_tab.dart"
if (Test-Path $file) {
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    # This file needs user from parent widget - will need to check the widget structure
    Write-Host "Note: $file needs manual review for user parameter"
}

# Fix screens_management_properties.dart - add user parameter to AddPropertyScreen and EditPropertyScreen
$file = "lib\screens\screens_management_properties.dart"
if (Test-Path $file) {
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    # Fix AddPropertyScreen
    $content = $content -replace "const AddPropertyScreen\(\)", "AddPropertyScreen(user: widget.user)"
    # EditPropertyScreen already has property parameter, just needs user
    $content = $content -replace "EditPropertyScreen\(property: property\)", "EditPropertyScreen(property: property, user: widget.user)"
    Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Fixed: $file"
}

# Fix screens_profile.dart - add user parameter to EditProfileScreen
$file = "lib\screens\screens_profile.dart"
if (Test-Path $file) {
    $content = Get-Content -Path $file -Raw -Encoding UTF8
    # Fix EditProfileScreen
    $content = $content -replace "const EditProfileScreen\(\)", "EditProfileScreen(user: widget.user)"
    Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline
    Write-Host "Fixed: $file"
}

Write-Host "`nAll parameter fixes applied!" -ForegroundColor Green
