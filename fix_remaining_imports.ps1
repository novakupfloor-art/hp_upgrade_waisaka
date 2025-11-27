# PowerShell script to fix all remaining import paths

$files = @(
    "lib\screens\screens_search.dart",
    "lib\screens\screens_profile_management_tab.dart",
    "lib\screens\screens_profile.dart",
    "lib\screens\screens_management_properties.dart",
    "lib\screens\screens_login.dart",
    "lib\screens\screens_iklan_property_tab.dart",
    "lib\screens\screens_dashboard.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content -Path $file -Raw -Encoding UTF8
        
        # Fix all nested import paths
        $content = $content -replace "import 'property/property_detail\.dart'", "import 'screens_property_detail.dart'"
        $content = $content -replace "import 'auth/login_screen\.dart'", "import 'screens_login.dart'"
        $content = $content -replace "import 'auth/register_screen\.dart'", "import 'screens_register.dart'"
        $content = $content -replace "import 'auth/forgot_password_screen\.dart'", "import 'screens_forgot_password.dart'"
        $content = $content -replace "import 'profile/edit_profile_screen\.dart'", "import 'screens_edit_profile.dart'"
        $content = $content -replace "import 'profile/profile_screen\.dart'", "import 'screens_profile.dart'"
        $content = $content -replace "import 'dashboard-panel-users/add_property_screen\.dart'", "import 'screens_add_property.dart'"
        $content = $content -replace "import 'dashboard-panel-users/edit_property_screen\.dart'", "import 'screens_edit_property.dart'"
        $content = $content -replace "import 'dashboard-panel-users/management_properties_screen\.dart'", "import 'screens_management_properties.dart'"
        
        Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Fixed: $file" -ForegroundColor Green
    }
}

Write-Host "`nAll import paths fixed!" -ForegroundColor Cyan
