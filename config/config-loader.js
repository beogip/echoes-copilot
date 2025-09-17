// config/config-loader.js - Utility to load echo configuration
const fs = require('fs');
const path = require('path');

class EchoConfig {
    constructor() {
        this.configPath = path.join(__dirname, 'echo-constants.json');
        this.config = null;
        this.loadConfig();
    }

    loadConfig() {
        try {
            const configData = fs.readFileSync(this.configPath, 'utf8');
            this.config = JSON.parse(configData);
        } catch (error) {
            throw new Error(`Failed to load echo configuration: ${error.message}`);
        }
    }

    // Path utilities
    getPromptsDir() {
        return this.config.paths.prompts_dir;
    }

    getGithubDir() {
        return this.config.paths.github_dir;
    }

    getCopilotInstructionsPath() {
        return this.config.paths.copilot_instructions;
    }

    // File utilities
    getFileExtension() {
        return this.config.files.extension;
    }

    getCopilotFilename() {
        return this.config.files.copilot_filename;
    }

    // Echo utilities
    getEchoNames() {
        return this.config.echos.map(echo => echo.name);
    }

    getEchoFiles() {
        return this.config.echos.map(echo => `${echo.name}${this.getFileExtension()}`);
    }

    getEchoByName(name) {
        return this.config.echos.find(echo => echo.name === name);
    }

    getAllEchos() {
        return this.config.echos;
    }

    // Build utilities
    getBuildConfig() {
        return this.config.build;
    }

    // Generate full paths
    getEchoFilePath(echoName) {
        return `${this.getPromptsDir()}/${echoName}${this.getFileExtension()}`;
    }

    // For shell scripts - generate shell-compatible strings
    getShellEchoFiles() {
        return this.getEchoFiles().map(f => `"${f}"`).join('\n        ');
    }
}

module.exports = EchoConfig;

// For direct usage
if (require.main === module) {
    const config = new EchoConfig();
    console.log('Echo Configuration:');
    console.log('- Prompts directory:', config.getPromptsDir());
    console.log('- File extension:', config.getFileExtension());
    console.log('- Echo files:', config.getEchoFiles());
}
