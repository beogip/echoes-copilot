#!/bin/bash
# 🧠🤖 Echos + Copilot Local Development Installer
# For local development and testing purposes

set -euo pipefail

# Configuration
SCRIPT_VERSION="1.0.0"
TARGET_PROJECT_DIR="${1:-}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTRUCTIONS_DIR="$SOURCE_DIR/.github/instructions"
COPILOT_FILE="$SOURCE_DIR/.github/copilot-instructions.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
INSTALL_MODE="instructions"
FORCE_INSTALL=false
VERBOSE=false

# Print functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Help function
show_help() {
    cat << EOF
🧠🤖 Echos + Copilot Local Development Installer v${SCRIPT_VERSION}

USAGE:
    ./install-local.sh [TARGET_DIRECTORY] [OPTIONS]

ARGUMENTS:
    TARGET_DIRECTORY       Path to the target project (default: current directory)

OPTIONS:
    -m, --mode MODE        Installation mode: 'instructions' (default) or 'comprehensive'
    -f, --force           Force installation, overwrite existing files
    -v, --verbose         Enable verbose output
    -h, --help            Show this help message

EXAMPLES:
    ./install-local.sh                           # Install in current directory
    ./install-local.sh /path/to/project          # Install in specific project
    ./install-local.sh . -m comprehensive -f    # Force comprehensive mode

NOTES:
    - This script copies from the local .github directory
    - Run 'npm run build' first to ensure files are up to date
    - Use this for development and testing purposes

EOF
}

# Parse arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--mode)
                INSTALL_MODE="$2"
                if [[ "$INSTALL_MODE" != "instructions" && "$INSTALL_MODE" != "comprehensive" ]]; then
                    print_error "Invalid mode: $INSTALL_MODE. Use 'instructions' or 'comprehensive'"
                    exit 1
                fi
                shift 2
                ;;
            -f|--force)
                FORCE_INSTALL=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                if [[ -z "$TARGET_PROJECT_DIR" ]]; then
                    TARGET_PROJECT_DIR="$1"
                else
                    print_error "Multiple target directories specified"
                    exit 1
                fi
                shift
                ;;
        esac
    done
}

# Validate prerequisites
validate_prerequisites() {
    # Check if source files exist
    if [[ "$INSTALL_MODE" == "instructions" ]]; then
        if [[ ! -d "$INSTRUCTIONS_DIR" ]]; then
            print_error "Instructions directory not found: $INSTRUCTIONS_DIR"
            print_info "Run 'npm run build' first to generate the files"
            exit 1
        fi
    else
        if [[ ! -f "$COPILOT_FILE" ]]; then
            print_error "Copilot instructions file not found: $COPILOT_FILE"
            print_info "Run 'npm run build' first to generate the file"
            exit 1
        fi
    fi

    # Set default target directory
    if [[ -z "$TARGET_PROJECT_DIR" ]]; then
        TARGET_PROJECT_DIR="$(pwd)"
    fi

    # Resolve target directory
    TARGET_PROJECT_DIR="$(realpath "$TARGET_PROJECT_DIR")"
    
    if [[ ! -d "$TARGET_PROJECT_DIR" ]]; then
        print_error "Target directory does not exist: $TARGET_PROJECT_DIR"
        exit 1
    fi
}

# Create backup
create_backup() {
    local target_github="$TARGET_PROJECT_DIR/.github"
    
    if [[ ! -d "$target_github" ]]; then
        return 0
    fi

    local backup_dir="$target_github/echos-backup-$(date +%Y%m%d-%H%M%S)"
    
    print_info "Creating backup of existing files..."
    mkdir -p "$backup_dir"
    
    if [[ "$INSTALL_MODE" == "instructions" && -d "$target_github/instructions" ]]; then
        cp -r "$target_github/instructions" "$backup_dir/"
        print_success "Backed up instructions directory"
    elif [[ "$INSTALL_MODE" == "comprehensive" && -f "$target_github/copilot-instructions.md" ]]; then
        cp "$target_github/copilot-instructions.md" "$backup_dir/"
        print_success "Backed up copilot-instructions.md"
    fi
}

# Install files
install_files() {
    local target_github="$TARGET_PROJECT_DIR/.github"
    
    # Create .github directory if it doesn't exist
    mkdir -p "$target_github"
    
    if [[ "$INSTALL_MODE" == "instructions" ]]; then
        # Copy instructions directory
        if [[ "$FORCE_INSTALL" == true ]] || [[ ! -d "$target_github/instructions" ]]; then
            print_info "Installing instruction files..."
            cp -r "$INSTRUCTIONS_DIR" "$target_github/"
            print_success "Installed instructions to: $target_github/instructions/"
        else
            print_warning "Instructions directory already exists. Use --force to overwrite"
            exit 1
        fi
    else
        # Copy comprehensive file
        if [[ "$FORCE_INSTALL" == true ]] || [[ ! -f "$target_github/copilot-instructions.md" ]]; then
            print_info "Installing comprehensive file..."
            cp "$COPILOT_FILE" "$target_github/"
            print_success "Installed copilot-instructions.md to: $target_github/"
        else
            print_warning "copilot-instructions.md already exists. Use --force to overwrite"
            exit 1
        fi
    fi
}

# Validate installation
validate_installation() {
    local target_github="$TARGET_PROJECT_DIR/.github"
    
    if [[ "$INSTALL_MODE" == "instructions" ]]; then
        if [[ -d "$target_github/instructions" ]]; then
            local file_count=$(find "$target_github/instructions" -name "*.instructions.md" | wc -l)
            if [[ $file_count -gt 0 ]]; then
                print_success "Installation validated: $file_count instruction files found"
                return 0
            fi
        fi
        print_error "Installation validation failed: instructions not found"
        return 1
    else
        if [[ -f "$target_github/copilot-instructions.md" ]]; then
            print_success "Installation validated: copilot-instructions.md found"
            return 0
        fi
        print_error "Installation validation failed: copilot-instructions.md not found"
        return 1
    fi
}

# Main installation function
main() {
    echo -e "${BLUE}"
    cat << "EOF"
    🧠🤖 ECHOS + COPILOT LOCAL INSTALLER
    ====================================
    Local Development Installation
EOF
    echo -e "${NC}"
    
    parse_arguments "$@"
    validate_prerequisites
    
    print_info "Installing from: $SOURCE_DIR"
    print_info "Installing to: $TARGET_PROJECT_DIR"
    print_info "Mode: $INSTALL_MODE"
    
    create_backup
    install_files
    validate_installation
    
    print_success "Local installation completed successfully!"
    print_info "Target: $TARGET_PROJECT_DIR/.github/"
    
    if [[ "$VERBOSE" == true ]]; then
        print_info "Listing installed files:"
        if [[ "$INSTALL_MODE" == "instructions" ]]; then
            ls -la "$TARGET_PROJECT_DIR/.github/instructions/"
        else
            ls -la "$TARGET_PROJECT_DIR/.github/copilot-instructions.md"
        fi
    fi
}

# Run main function with all arguments
main "$@"