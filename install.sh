#!/bin/bash
# 🧠🤖 Echos + Copilot Template Installer
# Advanced installer script with backup, rollback, and cross-platform support

set -euo pipefail  # Strict error handling

# Encapsulation namespace for installer variables
INSTALLER_NAMESPACE="ECHOS_INSTALLER"

# Configuration (namespaced)
declare -r ECHOS_INSTALLER_SCRIPT_VERSION="1.0.0"
declare -r ECHOS_INSTALLER_GITHUB_REPO="https://api.github.com/repos/beogip/echos-copilot/contents"
declare -r ECHOS_INSTALLER_BACKUP_DIR=".github/echos-backup-$(date +%Y%m%d-%H%M%S)"
declare -r ECHOS_INSTALLER_TARGET_DIR=".github"
declare -r ECHOS_INSTALLER_LOG_FILE="/tmp/echos-copilot-install.log"

# Colors for output (namespaced)
declare -r ECHOS_INSTALLER_RED='\033[0;31m'
declare -r ECHOS_INSTALLER_GREEN='\033[0;32m'
declare -r ECHOS_INSTALLER_YELLOW='\033[1;33m'
declare -r ECHOS_INSTALLER_BLUE='\033[0;34m'
declare -r ECHOS_INSTALLER_NC='\033[0m' # No Color

# Global variables (namespaced)
ECHOS_INSTALLER_INSTALL_MODE="instructions"  # "instructions" or "comprehensive"
ECHOS_INSTALLER_FORCE_INSTALL=false
ECHOS_INSTALLER_VERBOSE=false
ECHOS_INSTALLER_ROLLBACK_AVAILABLE=false

# Alias variables for non-namespaced references
SCRIPT_VERSION="$ECHOS_INSTALLER_SCRIPT_VERSION"
GITHUB_REPO="$ECHOS_INSTALLER_GITHUB_REPO"
BACKUP_DIR="$ECHOS_INSTALLER_BACKUP_DIR"
TARGET_DIR="$ECHOS_INSTALLER_TARGET_DIR"
LOG_FILE="$ECHOS_INSTALLER_LOG_FILE"
INSTALL_MODE="$ECHOS_INSTALLER_INSTALL_MODE"
FORCE_INSTALL="$ECHOS_INSTALLER_FORCE_INSTALL"
VERBOSE="$ECHOS_INSTALLER_VERBOSE"
ROLLBACK_AVAILABLE="$ECHOS_INSTALLER_ROLLBACK_AVAILABLE"

# Logging function
installer_installer_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$ECHOS_INSTALLER_LOG_FILE"
    if [[ "$ECHOS_INSTALLER_VERBOSE" == true ]]; then
        echo -e "${ECHOS_INSTALLER_BLUE}[LOG]${ECHOS_INSTALLER_NC} $1"
    fi
}

# Wrapper functions for backwards compatibility
installer_log() { installer_installer_log "$@"; }
log() { installer_installer_log "$@"; }
installer_print_success() { installer_installer_print_success "$@"; }
installer_print_error() { installer_installer_print_error "$@"; }
installer_print_warning() { installer_installer_print_warning "$@"; }
installer_print_info() { installer_installer_print_info "$@"; }

# Print functions
installer_installer_print_success() {
    echo -e "${ECHOS_INSTALLER_GREEN}✅ $1${ECHOS_INSTALLER_NC}"
    installer_log "SUCCESS: $1"
}

installer_installer_print_error() {
    echo -e "${ECHOS_INSTALLER_RED}❌ $1${ECHOS_INSTALLER_NC}" >&2
    installer_log "ERROR: $1"
}

installer_installer_print_warning() {
    echo -e "${ECHOS_INSTALLER_YELLOW}⚠️  $1${ECHOS_INSTALLER_NC}"
    installer_log "WARNING: $1"
}

installer_installer_print_info() {
    echo -e "${ECHOS_INSTALLER_BLUE}ℹ️  $1${ECHOS_INSTALLER_NC}"
    installer_log "INFO: $1"
}

# Help function
show_help() {
    cat << EOF
🧠🤖 Echos + Copilot Template Installer v${ECHOS_INSTALLER_SCRIPT_VERSION}

USAGE:
    ./install.sh [OPTIONS]

OPTIONS:
    -m, --mode MODE         Installation mode: 'instructions' (default) or 'comprehensive'
    -f, --force            Force installation, overwrite existing files
    -v, --verbose          Enable verbose logging
    -h, --help             Show this help message
    --rollback             Rollback to previous installation (if backup exists)

MODES:
    instructions           Install individual instruction files (recommended)
    comprehensive          Install single copilot-instructions.md file

EXAMPLES:
    ./install.sh                              # Install individual instructions (recommended)
    ./install.sh -m comprehensive             # Install comprehensive file
    ./install.sh -f -v                        # Force install with verbose output
    ./install.sh --rollback                   # Rollback previous installation

EOF
}

# Parse command line arguments
parse_arguments() {
    local request_rollback=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--mode)
                ECHOS_INSTALLER_INSTALL_MODE="$2"
                if [[ "$ECHOS_INSTALLER_INSTALL_MODE" != "instructions" && "$ECHOS_INSTALLER_INSTALL_MODE" != "comprehensive" ]]; then
                    installer_installer_print_error "Invalid mode: $ECHOS_INSTALLER_INSTALL_MODE. Use 'instructions' or 'comprehensive'"
                    exit 1
                fi
                shift 2
                ;;
            -f|--force)
                ECHOS_INSTALLER_FORCE_INSTALL=true
                shift
                ;;
            -v|--verbose)
                ECHOS_INSTALLER_VERBOSE=true
                shift
                ;;
            --rollback)
                request_rollback=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                installer_installer_print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    if [[ "$request_rollback" == true ]]; then
        rollback_installation
        exit 0
    fi
}

# Check prerequisites
check_prerequisites() {
    installer_print_info "Checking prerequisites..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        installer_print_warning "Not in a git repository. Proceeding anyway..."
    fi
    
    # Check required tools
    local missing_tools=()
    
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing_tools+=("curl or wget")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        installer_print_warning "jq not found. Will use basic JSON parsing."
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        installer_print_error "Missing required tools: ${missing_tools[*]}"
        installer_print_info "Please install missing tools and try again."
        exit 1
    fi
    
    installer_print_success "Prerequisites check passed"
}

# Download function with fallback
download_file() {
    local url="$1"
    local output="$2"
    
    log "Downloading: $url -> $output"
    
    if command -v curl >/dev/null 2>&1; then
        if curl -fsSL "$url" -o "$output"; then
            return 0
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q "$url" -O "$output"; then
            return 0
        fi
    fi
    
    return 1
}

# Backup existing files
backup_existing_files() {
    if [[ ! -d "$TARGET_DIR" ]]; then
        log "No existing .github directory to backup"
        return 0
    fi
    
    installer_print_info "Creating backup of existing files..."
    
    mkdir -p "$BACKUP_DIR"
    
    if [[ "$ECHOS_INSTALLER_INSTALL_MODE" == "instructions" ]]; then
        # Backup instructions directory
        if [[ -d "$TARGET_DIR/instructions" ]]; then
            cp -r "$TARGET_DIR/instructions" "$BACKUP_DIR/"
            log "Backed up instructions directory"
        fi
    else
        # Backup copilot-instructions.md
        if [[ -f "$TARGET_DIR/copilot-instructions.md" ]]; then
            cp "$TARGET_DIR/copilot-instructions.md" "$BACKUP_DIR/"
            log "Backed up copilot-instructions.md"
        fi
    fi
    
    ECHOS_INSTALLER_ROLLBACK_AVAILABLE=true
    installer_print_success "Backup created at: $BACKUP_DIR"
}

# Install individual instruction files
install_instructions() {
    installer_print_info "Installing individual instruction files..."
    
    local instructions_dir="$TARGET_DIR/instructions"
    mkdir -p "$instructions_dir"
    
    # List of instruction files to download
    local files=(
        "diagnostic-Diagnostic.instructions.md"
        "planning-Formative.instructions.md"
        "evaluation-Evaluative.instructions.md"
        "optimization-Technical.instructions.md"
        "coherence-Self-correction.instructions.md"
        "prioritization-Decisional.instructions.md"
    )
    
    local failed_downloads=()
    
    for file in "${files[@]}"; do
        local url="${GITHUB_REPO}/.github/instructions/${file}"
        local output="$instructions_dir/$file"
        
        installer_print_info "Downloading $file..."
        
        if ! download_file "$url" "$output"; then
            failed_downloads+=("$file")
            installer_print_error "Failed to download $file"
        else
            installer_print_success "Downloaded $file"
        fi
    done
    
    if [[ ${#failed_downloads[@]} -gt 0 ]]; then
        installer_print_error "Failed to download ${#failed_downloads[@]} files: ${failed_downloads[*]}"
        return 1
    fi
    
    installer_print_success "All instruction files installed successfully"
}

# Install comprehensive file
install_comprehensive() {
    installer_print_info "Installing comprehensive copilot-instructions.md..."
    
    local url="${GITHUB_REPO}/.github/copilot-instructions.md"
    local output="$TARGET_DIR/copilot-instructions.md"
    
    if ! download_file "$url" "$output"; then
        installer_print_error "Failed to download copilot-instructions.md"
        return 1
    fi
    
    installer_print_success "Comprehensive file installed successfully"
}

# Validate installation
validate_installation() {
    installer_print_info "Validating installation..."
    
    if [[ "$ECHOS_INSTALLER_INSTALL_MODE" == "instructions" ]]; then
        local instructions_dir="$TARGET_DIR/instructions"
        if [[ ! -d "$instructions_dir" ]]; then
            installer_print_error "Instructions directory not found"
            return 1
        fi
        
        local file_count=$(find "$instructions_dir" -name "*.instructions.md" | wc -l)
        if [[ $file_count -lt 6 ]]; then
            installer_print_error "Expected 6 instruction files, found $file_count"
            return 1
        fi
        
        installer_print_success "Found $file_count instruction files"
    else
        if [[ ! -f "$TARGET_DIR/copilot-instructions.md" ]]; then
            installer_print_error "copilot-instructions.md not found"
            return 1
        fi
        
        local file_size=$(wc -c < "$TARGET_DIR/copilot-instructions.md")
        if [[ $file_size -lt 1000 ]]; then
            installer_print_error "copilot-instructions.md seems too small ($file_size bytes)"
            return 1
        fi
        
        installer_print_success "copilot-instructions.md validated ($(( file_size / 1024 ))KB)"
    fi
    
    installer_print_success "Installation validation passed"
}

# Rollback installation
rollback_installation() {
    installer_print_info "Looking for backup to rollback..."
    
    local latest_backup
    latest_backup=$(find . -maxdepth 1 -name ".github/echos-backup-*" -type d | sort -r | head -n1)
    
    if [[ -z "$latest_backup" ]]; then
        installer_print_error "No backup found for rollback"
        exit 1
    fi
    
    installer_print_info "Found backup: $latest_backup"
    installer_print_warning "This will restore files from backup and remove current installation"
    
    read -p "Continue with rollback? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        installer_print_info "Rollback cancelled"
        exit 0
    fi
    
    # Remove current files
    if [[ -d "$TARGET_DIR/instructions" ]]; then
        rm -rf "$TARGET_DIR/instructions"
    fi
    if [[ -f "$TARGET_DIR/copilot-instructions.md" ]]; then
        rm -f "$TARGET_DIR/copilot-instructions.md"
    fi
    
    # Restore from backup
    if [[ -d "$latest_backup/instructions" ]]; then
        cp -r "$latest_backup/instructions" "$TARGET_DIR/"
    fi
    if [[ -f "$latest_backup/copilot-instructions.md" ]]; then
        cp "$latest_backup/copilot-instructions.md" "$TARGET_DIR/"
    fi
    
    installer_print_success "Rollback completed successfully"
}

# Check for conflicts
check_conflicts() {
    if [[ "$ECHOS_INSTALLER_FORCE_INSTALL" == true ]]; then
        return 0
    fi
    
    local conflicts=false
    
    if [[ "$ECHOS_INSTALLER_INSTALL_MODE" == "instructions" ]]; then
        if [[ -d "$TARGET_DIR/instructions" ]]; then
            installer_print_warning "Instructions directory already exists"
            conflicts=true
        fi
    else
        if [[ -f "$TARGET_DIR/copilot-instructions.md" ]]; then
            installer_print_warning "copilot-instructions.md already exists"
            conflicts=true
        fi
    fi
    
    if [[ "$conflicts" == true ]]; then
        installer_print_info "Existing files will be backed up to a backup directory before installation"
        read -p "Continue with installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            installer_print_info "Installation cancelled by user"
            exit 0
        fi
    fi
}

# Main installation function
main() {
    echo "🧠🤖 Echos + Copilot Template Installer v${SCRIPT_VERSION}"
    echo "=================================================="
    
    parse_arguments "$@"

    # Refresh alias variables after argument parsing
    INSTALL_MODE="$ECHOS_INSTALLER_INSTALL_MODE"
    FORCE_INSTALL="$ECHOS_INSTALLER_FORCE_INSTALL"
    VERBOSE="$ECHOS_INSTALLER_VERBOSE"
    TARGET_DIR="$ECHOS_INSTALLER_TARGET_DIR"
    BACKUP_DIR="$ECHOS_INSTALLER_BACKUP_DIR"
    LOG_FILE="$ECHOS_INSTALLER_LOG_FILE"
    SCRIPT_VERSION="$ECHOS_INSTALLER_SCRIPT_VERSION"

    installer_print_info "Installation mode: $INSTALL_MODE"
    installer_print_info "Force install: $FORCE_INSTALL"
    installer_print_info "Verbose logging: $VERBOSE"
    
    check_prerequisites
    check_conflicts
    backup_existing_files
    
    # Create target directory
    mkdir -p "$TARGET_DIR"
    
    # Install based on mode
    if [[ "$ECHOS_INSTALLER_INSTALL_MODE" == "instructions" ]]; then
        if ! install_instructions; then
            installer_print_error "Installation failed"
            if [[ "$ECHOS_INSTALLER_ROLLBACK_AVAILABLE" == true ]]; then
                installer_print_info "Run './install.sh --rollback' to restore backup"
            fi
            exit 1
        fi
    else
        if ! install_comprehensive; then
            installer_print_error "Installation failed"
            if [[ "$ECHOS_INSTALLER_ROLLBACK_AVAILABLE" == true ]]; then
                installer_print_info "Run './install.sh --rollback' to restore backup"
            fi
            exit 1
        fi
    fi
    
    validate_installation
    
    echo "=================================================="
    installer_print_success "🎉 Installation completed successfully!"
    echo ""
    installer_print_info "Next steps:"
    if [[ "$ECHOS_INSTALLER_INSTALL_MODE" == "instructions" ]]; then
        echo "  1. GitHub Copilot will automatically load the instruction files"
        echo "  2. Use // ECHO: <echo_name> in your code comments"
        echo "  3. Available echos: diagnostic, planning, evaluation, optimization, coherence, prioritization"
    else
        echo "  1. Copy the content of .github/copilot-instructions.md"
        echo "  2. Paste it in GitHub Copilot Settings > Instructions"
        echo "  3. Use // ECHO: <echo_name> in your code comments"
    fi
    echo ""
    installer_print_info "Documentation: https://github.com/beogip/echos-copilot"
    installer_print_info "Log file: $LOG_FILE"
    
    if [[ "$ECHOS_INSTALLER_ROLLBACK_AVAILABLE" == true ]]; then
        installer_print_info "Backup available at: $BACKUP_DIR"
        installer_print_info "Run './install.sh --rollback' if you need to revert"
    fi
}

# Only run main function if script is executed directly, not sourced
# Also respect TESTING_MODE environment variable
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] && [[ "${TESTING_MODE:-}" != "1" ]]; then
    main "$@"
fi
