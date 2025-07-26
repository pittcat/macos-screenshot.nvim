# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of macos-screenshot.nvim
- Multiple screenshot capture modes (full, window, selection, interactive)
- Automatic clipboard integration with configurable path formats
- Intelligent file naming and organization
- Comprehensive logging system with structured output
- Health check system for troubleshooting
- Complete test suite with unit and integration tests
- Professional documentation with Vim help files
- Built using base.nvim template for best practices

### Features
- 🖼️ **Multi-mode Screenshots** - Support for full screen, window, selection, and interactive capture
- 📋 **Smart Clipboard** - Automatic path copying with format options (absolute, relative, home)
- 📁 **File Management** - Smart naming, directory organization, duplicate detection
- 📊 **Professional Logging** - Structured logging with multiple levels and output options
- ⚙️ **Highly Configurable** - Extensive customization options and keybindings
- 🔍 **Health Monitoring** - Complete system status monitoring and permission checks
- 🧪 **Full Testing** - Comprehensive test coverage with automated CI/CD
- 📖 **Complete Documentation** - Vim help docs, usage guides, and API reference

### Technical
- Based on base.nvim template architecture
- Integrated logging system (simplified vlog.nvim)
- LuaCATS type annotations throughout
- Lua 5.1+ compatible
- Neovim 0.7+ required (0.10+ recommended)
- macOS-specific implementation
- Zero external dependencies

### Documentation
- Complete README with installation and usage
- Vim help documentation (`:help macos-screenshot`)
- Architecture and design documentation
- Test coverage and CI/CD setup
- Reproduction environment for debugging

### Commands Added
- `:Screenshot [type] [basename]` - Primary screenshot command
- `:ScreenshotFull` - Full screen capture
- `:ScreenshotWindow` - Window capture
- `:ScreenshotSelection` - Selection capture
- `:ScreenshotInteractive` - Interactive capture
- `:ScreenshotOpenLast` - Open last screenshot
- `:ScreenshotRevealLast` - Reveal in Finder
- `:ScreenshotInfo` - Show screenshot info
- `:MacosScreenshotSetup` - Basic setup command

### API Added
- `require("macos-screenshot").setup(opts)` - Plugin initialization
- `require("macos-screenshot").take_screenshot(type, basename)` - Core screenshot function
- `require("macos-screenshot").get_last_screenshot()` - Get last screenshot path
- `require("macos-screenshot").is_initialized()` - Check initialization status
- Complete Lua API for programmatic usage

### Configuration
- Extensive configuration options for all aspects
- Smart defaults that work out of the box
- Configurable keybindings and paths
- Logging level and output control
- Screenshot behavior customization

### Testing
- Unit tests for all modules
- Integration tests for core functionality
- Health check validation
- CI/CD pipeline with GitHub Actions
- Test environment and reproduction setup

## [1.0.0] - TBD

### Added
- Initial public release
- All features listed above
- Complete documentation
- Stable API