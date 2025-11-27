# PowerShell script to update import statements
$libPath = "lib"

# Get all dart files
$dartFiles = Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse | Where-Object {
    $_.FullName -notmatch "\\build\\" -and 
    $_.FullName -notmatch "\\.dart_tool\\" -and
    $_.FullName -notmatch "\\generated\\"
}

$updatedCount = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Update model imports
    $content = $content -replace "import '(\.\./)+models/article\.dart'", "import '`$1models/models_article.dart'"
    $content = $content -replace "import '(\.\./)+models/property\.dart'", "import '`$1models/models_property.dart'"
    $content = $content -replace "import '(\.\./)+models/user\.dart'", "import '`$1models/models_user.dart'"
    
    # Update provider imports
    $content = $content -replace "import '(\.\./)+providers/article_provider\.dart'", "import '`$1providers/providers_article.dart'"
    $content = $content -replace "import '(\.\./)+providers/property_provider\.dart'", "import '`$1providers/providers_property.dart'"
    $content = $content -replace "import '(\.\./)+providers/api_routes\.dart'", "import '`$1providers/providers_api_routes.dart'"
    
    # Update screen imports - remove nested paths
    $content = $content -replace "import '(\.\./)+screens/admin/admin_dashboard\.dart'", "import '`$1screens/screens_admin_dashboard.dart'"
    $content = $content -replace "import '(\.\./)+screens/admin/tabs/admin_article_tab\.dart'", "import '`$1screens/screens_admin_article_tab.dart'"
    $content = $content -replace "import '(\.\./)+screens/admin/tabs/admin_paket_tab\.dart'", "import '`$1screens/screens_admin_paket_tab.dart'"
    $content = $content -replace "import '(\.\./)+screens/admin/tabs/admin_statistik_tab\.dart'", "import '`$1screens/screens_admin_statistik_tab.dart'"
    $content = $content -replace "import '(\.\./)+screens/admin/tabs/admin_transaksi_tab\.dart'", "import '`$1screens/screens_admin_transaksi_tab.dart'"
    $content = $content -replace "import '(\.\./)+screens/article/article_detail_screen\.dart'", "import '`$1screens/screens_article_detail.dart'"
    $content = $content -replace "import '(\.\./)+screens/auth/forgot_password_screen\.dart'", "import '`$1screens/screens_forgot_password.dart'"
    $content = $content -replace "import '(\.\./)+screens/auth/login_screen\.dart'", "import '`$1screens/screens_login.dart'"
    $content = $content -replace "import '(\.\./)+screens/auth/register_screen\.dart'", "import '`$1screens/screens_register.dart'"
    $content = $content -replace "import '(\.\./)+screens/dashboard-panel-users/add_property_screen\.dart'", "import '`$1screens/screens_add_property.dart'"
    $content = $content -replace "import '(\.\./)+screens/dashboard-panel-users/dashboard_screen\.dart'", "import '`$1screens/screens_dashboard.dart'"
    $content = $content -replace "import '(\.\./)+screens/dashboard-panel-users/edit_profile_screen\.dart'", "import '`$1screens/screens_edit_profile.dart'"
    $content = $content -replace "import '(\.\./)+screens/dashboard-panel-users/edit_property_screen\.dart'", "import '`$1screens/screens_edit_property.dart'"
    $content = $content -replace "import '(\.\./)+screens/dashboard-panel-users/management_properties_screen\.dart'", "import '`$1screens/screens_management_properties.dart'"
    $content = $content -replace "import '(\.\./)+screens/dashboard-panel-users/profile_screen\.dart'", "import '`$1screens/screens_profile.dart'"
    $content = $content -replace "import '(\.\./)+screens/property/property_detail\.dart'", "import '`$1screens/screens_property_detail.dart'"
    $content = $content -replace "import '(\.\./)+screens/property/search_screen\.dart'", "import '`$1screens/screens_search.dart'"
    $content = $content -replace "import '(\.\./)+screens/staff/staff_dashboard\.dart'", "import '`$1screens/screens_staff_dashboard.dart'"
    $content = $content -replace "import '(\.\./)+screens/staff/tabs/iklan_property_tab\.dart'", "import '`$1screens/screens_iklan_property_tab.dart'"
    $content = $content -replace "import '(\.\./)+screens/staff/tabs/paket_iklan_tab\.dart'", "import '`$1screens/screens_paket_iklan_tab.dart'"
    $content = $content -replace "import '(\.\./)+screens/staff/tabs/profile_management_tab\.dart'", "import '`$1screens/screens_profile_management_tab.dart'"
    $content = $content -replace "import '(\.\./)+screens/staff/tabs/statistik_tab\.dart'", "import '`$1screens/screens_statistik_tab.dart'"
    $content = $content -replace "import '(\.\./)+screens/splash_screen\.dart'", "import '`$1screens/screens_splash.dart'"
    
    # If content changed, write it back
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $relativePath = $file.FullName.Substring($PWD.Path.Length + 1)
        Write-Host "Updated: $relativePath"
        $updatedCount++
    }
}

Write-Host "`nCompleted! Updated $updatedCount files." -ForegroundColor Green
