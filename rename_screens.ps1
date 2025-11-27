# PowerShell script to rename and move screen files
# Following naming convention: screens_[name].dart

$moves = @(
    @{src="lib\screens\admin\admin_dashboard.dart"; dst="lib\screens\screens_admin_dashboard.dart"},
    @{src="lib\screens\admin\tabs\admin_article_tab.dart"; dst="lib\screens\screens_admin_article_tab.dart"},
    @{src="lib\screens\admin\tabs\admin_paket_tab.dart"; dst="lib\screens\screens_admin_paket_tab.dart"},
    @{src="lib\screens\admin\tabs\admin_statistik_tab.dart"; dst="lib\screens\screens_admin_statistik_tab.dart"},
    @{src="lib\screens\admin\tabs\admin_transaksi_tab.dart"; dst="lib\screens\screens_admin_transaksi_tab.dart"},
    @{src="lib\screens\article\article_detail_screen.dart"; dst="lib\screens\screens_article_detail.dart"},
    @{src="lib\screens\auth\forgot_password_screen.dart"; dst="lib\screens\screens_forgot_password.dart"},
    @{src="lib\screens\auth\login_screen.dart"; dst="lib\screens\screens_login.dart"},
    @{src="lib\screens\auth\register_screen.dart"; dst="lib\screens\screens_register.dart"},
    @{src="lib\screens\dashboard-panel-users\add_property_screen.dart"; dst="lib\screens\screens_add_property.dart"},
    @{src="lib\screens\dashboard-panel-users\dashboard_screen.dart"; dst="lib\screens\screens_dashboard.dart"},
    @{src="lib\screens\dashboard-panel-users\edit_profile_screen.dart"; dst="lib\screens\screens_edit_profile.dart"},
    @{src="lib\screens\dashboard-panel-users\edit_property_screen.dart"; dst="lib\screens\screens_edit_property.dart"},
    @{src="lib\screens\dashboard-panel-users\management_properties_screen.dart"; dst="lib\screens\screens_management_properties.dart"},
    @{src="lib\screens\dashboard-panel-users\profile_screen.dart"; dst="lib\screens\screens_profile.dart"},
    @{src="lib\screens\property\property_detail.dart"; dst="lib\screens\screens_property_detail.dart"},
    @{src="lib\screens\property\search_screen.dart"; dst="lib\screens\screens_search.dart"},
    @{src="lib\screens\staff\staff_dashboard.dart"; dst="lib\screens\screens_staff_dashboard.dart"},
    @{src="lib\screens\staff\tabs\iklan_property_tab.dart"; dst="lib\screens\screens_iklan_property_tab.dart"},
    @{src="lib\screens\staff\tabs\paket_iklan_tab.dart"; dst="lib\screens\screens_paket_iklan_tab.dart"},
    @{src="lib\screens\staff\tabs\profile_management_tab.dart"; dst="lib\screens\screens_profile_management_tab.dart"},
    @{src="lib\screens\staff\tabs\statistik_tab.dart"; dst="lib\screens\screens_statistik_tab.dart"},
    @{src="lib\screens\splash_screen.dart"; dst="lib\screens\screens_splash.dart"}
)

foreach ($move in $moves) {
    if (Test-Path $move.src) {
        Move-Item -Path $move.src -Destination $move.dst -Force
        Write-Host "Moved: $($move.src) -> $($move.dst)"
    } else {
        Write-Host "Not found: $($move.src)" -ForegroundColor Yellow
    }
}

# Remove empty directories
$emptyDirs = @(
    "lib\screens\admin\tabs",
    "lib\screens\admin",
    "lib\screens\article",
    "lib\screens\auth",
    "lib\screens\dashboard-panel-users",
    "lib\screens\property",
    "lib\screens\staff\tabs",
    "lib\screens\staff"
)

foreach ($dir in $emptyDirs) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Force -ErrorAction SilentlyContinue
        Write-Host "Removed empty directory: $dir"
    }
}

Write-Host "`nScreen files reorganization completed!" -ForegroundColor Green
