#!/usr/bin/env node
// scripts/build/generate-build-config.js - Generate build-config.json from centralized constants

const path = require('path');
const fs = require('fs');

// Load centralized configuration
const EchoConfig = require('../../config/config-loader.js');

function generateBuildConfig() {
    try {
        const config = new EchoConfig();
        const buildConstants = config.getBuildConfig();
        
        // Generate build configuration
        const buildConfig = {
            sourceDir: `../../${buildConstants.source_dir}`,
            outputFile: buildConstants.output_file,
            outputDir: "../../.github",
            instructionsDir: `../../${config.getPromptsDir()}`,
            echoProtocolDir: `../../${buildConstants.echo_protocol_dir}`,
            echos: config.getAllEchos().map(echo => ({
                name: echo.name,
                file: echo.file,
                emoji: echo.emoji,
                trigger: echo.trigger
            }))
        };
        
        // Write build configuration
        const buildConfigPath = path.join(__dirname, 'build-config.json');
        fs.writeFileSync(buildConfigPath, JSON.stringify(buildConfig, null, 2));
        
        console.log('✅ Generated build-config.json from centralized constants');
        console.log(`📁 Config location: ${buildConfigPath}`);
        console.log(`🔧 Echos configured: ${buildConfig.echos.length}`);
        
    } catch (error) {
        console.error('❌ Failed to generate build config:', error.message);
        process.exit(1);
    }
}

if (require.main === module) {
    generateBuildConfig();
}

module.exports = { generateBuildConfig };
