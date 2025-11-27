import os
import re

# Mapping of old import paths to new import paths
import_replacements = {
    # Models
    r"from '\.\./models/article\.dart'": "from '../models/models_article.dart'",
    r"from '\.\./\.\./models/article\.dart'": "from '../../models/models_article.dart'",
    r"from '\.\./\.\./\.\./models/article\.dart'": "from '../../../models/models_article.dart'",
    r"from 'models/article\.dart'": "from 'models/models_article.dart'",
    
    r"from '\.\./models/property\.dart'": "from '../models/models_property.dart'",
    r"from '\.\./\.\./models/property\.dart'": "from '../../models/models_property.dart'",
    r"from '\.\./\.\./\.\./models/property\.dart'": "from '../../../models/models_property.dart'",
    r"from 'models/property\.dart'": "from 'models/models_property.dart'",
    
    r"from '\.\./models/user\.dart'": "from '../models/models_user.dart'",
    r"from '\.\./\.\./models/user\.dart'": "from '../../models/models_user.dart'",
    r"from '\.\./\.\./\.\./models/user\.dart'": "from '../../../models/models_user.dart'",
    r"from 'models/user\.dart'": "from 'models/models_user.dart'",
    
    # Providers
    r"from '\.\./providers/article_provider\.dart'": "from '../providers/providers_article.dart'",
    r"from '\.\./\.\./providers/article_provider\.dart'": "from '../../providers/providers_article.dart'",
    
    r"from '\.\./providers/property_provider\.dart'": "from '../providers/providers_property.dart'",
    r"from '\.\./\.\./providers/property_provider\.dart'": "from '../../providers/providers_property.dart'",
    
    r"from '\.\./providers/api_routes\.dart'": "from '../providers/providers_api_routes.dart'",
    r"from '\.\./\.\./providers/api_routes\.dart'": "from '../../providers/providers_api_routes.dart'",
    
    # Screens - old nested paths to new flat paths
    r"from '\.\./screens/auth/login_screen\.dart'": "from '../screens/screens_login.dart'",
    r"from '\.\./\.\./screens/auth/login_screen\.dart'": "from '../../screens/screens_login.dart'",
    r"from 'screens/auth/login_screen\.dart'": "from 'screens/screens_login.dart'",
    
    r"from '\.\./screens/auth/register_screen\.dart'": "from '../screens/screens_register.dart'",
    r"from '\.\./\.\./screens/auth/register_screen\.dart'": "from '../../screens/screens_register.dart'",
    
    r"from '\.\./screens/property/property_detail\.dart'": "from '../screens/screens_property_detail.dart'",
    r"from '\.\./\.\./screens/property/property_detail\.dart'": "from '../../screens/screens_property_detail.dart'",
}

def update_imports_in_file(file_path):
    """Update import statements in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Replace all import patterns
        for old_pattern, new_path in import_replacements.items():
            content = re.sub(old_pattern, new_path, content)
        
        # If content changed, write it back
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def find_dart_files(root_dir):
    """Find all .dart files in directory"""
    dart_files = []
    for root, dirs, files in os.walk(root_dir):
        # Skip build and generated directories
        if 'build' in root or '.dart_tool' in root or 'generated' in root:
            continue
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

# Main execution
lib_dir = r"c:\Users\Music\Music\hp_upgrade_waisaka\lib"
dart_files = find_dart_files(lib_dir)

print(f"Found {len(dart_files)} Dart files to process...")
updated_count = 0

for file_path in dart_files:
    if update_imports_in_file(file_path):
        updated_count += 1
        print(f"Updated: {os.path.relpath(file_path, lib_dir)}")

print(f"\nCompleted! Updated {updated_count} files.")
