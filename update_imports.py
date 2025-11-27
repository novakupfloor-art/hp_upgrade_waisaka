import re
import os

# Mapping of old ApiService methods to new routes
replacements = {
    # Auth routes
    r"ApiService\.login\(": "AuthRoutes.login(",
    r"ApiService\.logout\(\)": "AuthRoutes.logout()",
    r"ApiService\.getCurrentUser\(\)": "AuthRoutes.getCurrentUser()",
    r"ApiService\.signup\(": "AuthRoutes.signup(",
    r"ApiService\.forgotPassword\(": "AuthRoutes.forgotPassword(",
    r"ApiService\.resetPassword\(": "AuthRoutes.resetPassword(",
    r"ApiService\.updateProfile\(": "AuthRoutes.updateProfile(",
    r"ApiService\.register\(": "AuthRoutes.register(",
    
    # Property routes
    r"ApiService\.getProperties\(": "PropertyRoutes.getProperties(",
    r"ApiService\.getPropertyDetail\(": "PropertyRoutes.getPropertyDetail(",
    r"ApiService\.searchProperties\(": "PropertyRoutes.searchProperties(",
    r"ApiService\.getMyProperties\(": "PropertyRoutes.getMyProperties(",
    r"ApiService\.getStaffProperties\(": "PropertyRoutes.getStaffProperties(",
    r"ApiService\.addProperty\(": "PropertyRoutes.addProperty(",
    r"ApiService\.updateProperty\(": "PropertyRoutes.updateProperty(",
    r"ApiService\.deleteProperty\(": "PropertyRoutes.deleteProperty(",
    
    # Article routes
    r"ApiService\.getArticles\(": "ArticleRoutes.getArticles(",
}

# Import replacements based on file location
def get_import_path(file_path):
    if 'auth' in file_path:
        return "import '../../providers/api_routes/auth_routes.dart';"
    elif 'dashboard-panel-users' in file_path:
        # Might need both auth and property
        return "import '../../providers/api_routes/auth_routes.dart';\nimport '../../providers/api_routes/property_routes.dart';"
    elif 'property' in file_path:
        return "import '../../providers/api_routes/property_routes.dart';"
    elif 'staff/tabs' in file_path:
        return "import '../../../providers/api_routes/auth_routes.dart';\nimport '../../../providers/api_routes/property_routes.dart';"
    else:
        return "import '../providers/api_routes/auth_routes.dart';"

files_to_update = [
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\auth\forgot_password_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\auth\login_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\auth\register_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\dashboard-panel-users\add_property_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\dashboard-panel-users\dashboard_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\dashboard-panel-users\edit_profile_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\dashboard-panel-users\edit_property_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\dashboard-panel-users\my_properties_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\property\search_screen.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\staff\tabs\iklan_property_tab.dart",
    r"c:\Users\Music\Music\hp_upgrade_waisaka\lib\screens\staff\tabs\profile_management_tab.dart",
]

for file_path in files_to_update:
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
        continue
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace import
    old_import_patterns = [
        r"import '\.\.\/\.\.\/services\/api_service\.dart';",
        r"import '\.\.\/\.\.\/\.\.\/services\/api_service\.dart';",
    ]
    
    new_import = get_import_path(file_path)
    
    for pattern in old_import_patterns:
        content = re.sub(pattern, new_import, content)
    
    # Replace method calls
    for old, new in replacements.items():
        content = re.sub(old, new, content)
    
    # Write back
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Updated: {file_path}")

print("\nAll files updated successfully!")
