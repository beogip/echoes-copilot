#!/bin/bash
# config/load-config.sh - Shell utility to load echo configuration

# Function to load echo configuration
load_echo_config() {
    local config_file="$(dirname "$0")/config/echo-constants.json"
    
    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        # Fallback for scripts in subdirectories
        config_file="$(dirname "$0")/../config/echo-constants.json"
        if [[ ! -f "$config_file" ]]; then
            echo "Warning: Could not find echo-constants.json, using defaults" >&2
            return 1
        fi
    fi
    
    # Load configuration using node (if available)
    if command -v node >/dev/null 2>&1; then
        echo "Loading configuration from $config_file" >&2
        export ECHO_CONFIG_FILE="$config_file"
        return 0
    else
        echo "Warning: Node.js not available, using hardcoded defaults" >&2
        return 1
    fi
}

# Function to get echo files list
get_echo_files() {
    local config_loader="$(dirname "$0")/config/config-loader.js"
    if [[ ! -f "$config_loader" ]]; then
        config_loader="$(dirname "$0")/../config/config-loader.js"
    fi
    
    if [[ -f "$config_loader" ]] && command -v node >/dev/null 2>&1; then
        node -e "
        const EchoConfig = require('$config_loader');
        const config = new EchoConfig();
        console.log(config.getEchoFiles().join(' '));
        "
    else
        echo "diagnostic.prompt.md planning.prompt.md evaluation.prompt.md optimization.prompt.md coherence.prompt.md prioritization.prompt.md"
    fi
}

# Function to get prompts directory
get_prompts_dir() {
    local config_loader="$(dirname "$0")/config/config-loader.js"
    if [[ ! -f "$config_loader" ]]; then
        config_loader="$(dirname "$0")/../config/config-loader.js"
    fi
    
    if [[ -f "$config_loader" ]] && command -v node >/dev/null 2>&1; then
        node -e "
        const EchoConfig = require('$config_loader');
        const config = new EchoConfig();
        console.log(config.getPromptsDir());
        "
    else
        echo ".github/prompts"
    fi
}

# Function to get file extension
get_file_extension() {
    local config_loader="$(dirname "$0")/config/config-loader.js"
    if [[ ! -f "$config_loader" ]]; then
        config_loader="$(dirname "$0")/../config/config-loader.js"
    fi
    
    if [[ -f "$config_loader" ]] && command -v node >/dev/null 2>&1; then
        node -e "
        const EchoConfig = require('$config_loader');
        const config = new EchoConfig();
        console.log(config.getFileExtension());
        "
    else
        echo ".prompt.md"
    fi
}

# Export functions for sourcing
export -f load_echo_config
export -f get_echo_files  
export -f get_prompts_dir
export -f get_file_extension
