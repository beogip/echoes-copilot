#!/bin/bash
# Script to fix namespace issues in installer scripts

echo "🔧 Fixing variable namespaces in installer scripts..."

# Fix install.sh
sed -i '' 's/print_error/installer_print_error/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/print_success/installer_print_success/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/print_warning/installer_print_warning/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/print_info/installer_print_info/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\blog(/installer_log(/g' /Users/beogip/Github/echos-copilot/install.sh

# Fix variable references
sed -i '' 's/\$SCRIPT_VERSION/$ECHOS_INSTALLER_SCRIPT_VERSION/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$GITHUB_REPO/$ECHOS_INSTALLER_GITHUB_REPO/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$BACKUP_DIR/$ECHOS_INSTALLER_BACKUP_DIR/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$TARGET_DIR/$ECHOS_INSTALLER_TARGET_DIR/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$LOG_FILE/$ECHOS_INSTALLER_LOG_FILE/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$INSTALL_MODE/$ECHOS_INSTALLER_INSTALL_MODE/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$FORCE_INSTALL/$ECHOS_INSTALLER_FORCE_INSTALL/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$VERBOSE/$ECHOS_INSTALLER_VERBOSE/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$ROLLBACK_AVAILABLE/$ECHOS_INSTALLER_ROLLBACK_AVAILABLE/g' /Users/beogip/Github/echos-copilot/install.sh

# Fix variable assignments (without $)
sed -i '' 's/INSTALL_MODE="/ECHOS_INSTALLER_INSTALL_MODE="/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/FORCE_INSTALL=/ECHOS_INSTALLER_FORCE_INSTALL=/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/VERBOSE=/ECHOS_INSTALLER_VERBOSE=/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/ROLLBACK_AVAILABLE=/ECHOS_INSTALLER_ROLLBACK_AVAILABLE=/g' /Users/beogip/Github/echos-copilot/install.sh

# Fix color references
sed -i '' 's/\$RED/$ECHOS_INSTALLER_RED/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$GREEN/$ECHOS_INSTALLER_GREEN/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$YELLOW/$ECHOS_INSTALLER_YELLOW/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$BLUE/$ECHOS_INSTALLER_BLUE/g' /Users/beogip/Github/echos-copilot/install.sh
sed -i '' 's/\$NC/$ECHOS_INSTALLER_NC/g' /Users/beogip/Github/echos-copilot/install.sh

echo "✅ Namespace fixes applied to install.sh"
