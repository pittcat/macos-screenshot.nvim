# macos-screenshot.nvim

A powerful and simple macOS screenshot plugin for Neovim.

## ✨ Features

- 🖼️ **Simple Screenshots** - Supports full screen and selection screenshots (two core modes)
- 📋 **Smart Clipboard** - Automatically copies screenshot path to system clipboard
- 📁 **File Management** - Smart naming, directory organization, duplicate detection
- 📊 **Professional Logging** - Integrated logging system with structured logs
- ⚙️ **Highly Configurable** - Rich customization options and keybindings
- 🔍 **Health Check** - Complete system status monitoring and permission detection
- 🧪 **Complete Testing** - Unit test and integration test coverage
- 📖 **Detailed Documentation** - Vim help documentation and usage guides

## 📋 System Requirements

- **Operating System**: macOS 10.15 (Catalina) or higher
- **Neovim**: 0.7+ (recommended 0.10+)
- **Commands**: `screencapture` (macOS built-in)
- **Permissions**: Screen Recording permission (required)

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    "pittcat/macos-screenshot.nvim",
    
    config = function()
        require("macos-screenshot").setup({
            save_path = "~/Documents/Screenshots",
            filename_format = "%Y%m%d_%H%M%S",
            copy_path_format = "home",  -- Use ~ path
            
            -- Debug mode configuration (optional)
            debug = {
                auto_enable = false,    -- Set to true to auto-enable debug
                log_levels = {"info", "warn", "error"},
                save_system_info = true
            },
            
            keybindings = {
                enabled = true,
                full_screen = "<leader>ss",       -- Full screen screenshot
                selection = "<leader>sp"          -- Selection screenshot
            }
        })
    end,
    
    -- Lazy loading
    cmd = {
        "Screenshot",
        "ScreenshotSelect"
    },
    
    keys = {
        { "<leader>ss", "<cmd>Screenshot<cr>", desc = "Full screen screenshot" },
        { "<leader>sp", "<cmd>ScreenshotSelect<cr>", desc = "Selection screenshot" },
    },
    
    -- Only load on macOS
    cond = function()
        return vim.fn.has("mac") == 1
    end,
}
```

## ⚙️ Configuration

### Default Configuration

```lua
require("macos-screenshot").setup({
    -- Basic settings
    save_path = "~/Desktop/Screenshots",  -- Screenshot save path
    filename_format = "%Y%m%d_%H%M%S",    -- Filename format (strftime)
    include_cursor = false,               -- Whether to include mouse cursor
    play_sound = false,                   -- Whether to play screenshot sound
    copy_path_format = "absolute",        -- Clipboard path format: "absolute", "relative", "home"
    monitor_screenshots = true,           -- Whether to monitor screenshot directory
    
    -- Log configuration
    log = {
        level = "info",                   -- Log level: trace, debug, info, warn, error, fatal
        use_console = true,               -- Console output
        use_file = true,                  -- File output
        highlights = true,                -- Syntax highlighting
        float_precision = 0.01           -- Float precision
    },
    
    -- Debug mode configuration
    debug = {
        auto_enable = false,              -- Whether to auto-enable debug mode
        log_levels = {"trace", "debug", "info", "warn"},  -- Log levels for debug mode
        save_system_info = true           -- Whether to save system information
    },
    
    -- Keybinding configuration
    keybindings = {
        enabled = true,                   -- Whether to enable keybindings
        full_screen = "<leader>ss",       -- Full screen screenshot
        selection = "<leader>sp"          -- Selection screenshot
    }
})
```

## 🎮 Usage

### Commands

```vim
" Core screenshot commands
:Screenshot                    " Full screen screenshot
:ScreenshotSelect             " Selection screenshot
```

### Keybindings (Default)

- `<leader>ss` - Full screen screenshot
- `<leader>sp` - Selection screenshot

### Lua API

```lua
local screenshot = require("macos-screenshot")

-- Screenshots
screenshot.take_screenshot("full")              -- Full screen screenshot
screenshot.take_screenshot("selection")         -- Selection screenshot

-- Status check
screenshot.is_initialized()                   -- Check if initialized
screenshot.get_config()                       -- Get current configuration
screenshot.get_state()                        -- Get plugin state (for debugging)
```

## 🔧 Health Check

Run health check to ensure the plugin works properly:

```vim
:checkhealth macos-screenshot
```

Health check verifies:
- macOS environment
- Neovim version compatibility
- `screencapture` command availability
- Screen recording permissions
- Save directory permissions
- Clipboard functionality
- Logging system

## 🐛 Debug Mode

The plugin supports detailed debug mode for troubleshooting and development debugging. Debug mode saves detailed logs to a fixed location for easy tracking and analysis.

### Enable Methods

#### 1. Enable via Commands (Recommended)
```vim
" Enable debug mode
:ScreenshotDebugEnable

" Disable debug mode
:ScreenshotDebugDisable
```

#### 2. Auto-enable in Configuration
```lua
require("macos-screenshot").setup({
    debug = {
        auto_enable = true,       -- Auto-enable debug mode
        log_levels = {"trace", "debug", "info", "warn"},  -- Supported log levels
        save_system_info = true   -- Save system info when enabled
    }
})
```

#### 3. Development Environment Configuration
```lua
-- Developers can use more detailed configuration
require("macos-screenshot").setup({
    log = {
        level = "debug",          -- Set log level to debug
        use_console = true,
        use_file = true
    },
    debug = {
        auto_enable = true,
        log_levels = {"trace", "debug", "info", "warn", "error"},
        save_system_info = true
    }
})
```

### Debug Features

**Fixed Log File**:
- 📁 **File Location**: `/tmp/macos-screenshot-debug.log`
- 🔄 **Update Strategy**: Each debug mode activation **replaces** the previous log
- 🔒 **Fixed Filename**: Easy to find and monitor, can use `tail -f` for monitoring
- 📈 **System Information**: Automatically records system environment and plugin state

**Log Level Support**:
- `trace` - Most detailed trace information
- `debug` - Debug information and variable states
- `info` - General information and operation results
- `warn` - Warning information
- `error` - Error information and exceptions

### Debug Log Content

**System Information**:
- 💻 macOS version and architecture information
- 🎯 Neovim version and API compatibility
- 📂 Working directory and plugin paths
- 🔧 Environment variables and configuration information

**Operation Records**:
- ⏱️ Detailed operation timeline and execution time
- 📷 Screenshot command construction and execution process
- 📄 File creation, size and path information
- 📎 Clipboard operations and path formatting

**Error Diagnosis**:
- 🚫 Detailed error stack traces
- 🔐 Permission checks and system requirement verification
- ⚠️ Warning and exception handling

**Debug Commands**:
```vim
:ScreenshotDebugEnable     " Enable debug mode
:ScreenshotDebugDisable    " Disable debug mode
:ScreenshotDebugLog        " Open debug log file
:ScreenshotDebugTail [N]   " Show last N lines of debug log
:ScreenshotDebugClear      " Clear debug log
:ScreenshotDebugInfo       " Show debug information
```

### Usage Examples

#### Basic Debug Workflow
```vim
" 1. Enable debug mode
:ScreenshotDebugEnable

" 2. Test screenshot functionality
:Screenshot

" 3. Check debug logs
:ScreenshotDebugTail 10    " View last 10 lines of log
:ScreenshotDebugLog        " Open complete log file

" 4. Disable debug mode
:ScreenshotDebugDisable
```

#### Advanced Debug Techniques
```bash
# Real-time log monitoring in terminal
tail -f /tmp/macos-screenshot-debug.log

# Find specific errors
grep -i error /tmp/macos-screenshot-debug.log

# View screenshot operations
grep "screenshot_" /tmp/macos-screenshot-debug.log
```

#### Troubleshooting Workflow
```vim
" 1. Check health status
:checkhealth macos-screenshot

" 2. Enable debug and get detailed info
:ScreenshotDebugEnable
:ScreenshotDebugInfo

" 3. Clear old logs and retest
:ScreenshotDebugClear
:Screenshot

" 4. View error logs
:ScreenshotDebugTail 20
```

### Common Issues & Solutions

**Q: Debug mode not effective?**
```vim
" Check debug status
:ScreenshotDebugInfo

" Ensure properly enabled
:ScreenshotDebugEnable
```

**Q: Can't find log file?**
```bash
# Find log file location
ls -la /tmp/macos-screenshot-debug.log

# Check directory permissions
ls -ld /tmp
```

**Q: Too much detailed logs?**
```lua
-- Adjust log levels
require("macos-screenshot").setup({
    debug = {
        log_levels = {"info", "warn", "error"}  -- Only show important info
    }
})
```

**Q: Performance impact?**
- Debug mode has slight performance impact, enable only when needed
- Disable promptly after use: `:ScreenshotDebugDisable`

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Integration with Claude Code

This plugin pairs perfectly with [claudecode.nvim](https://github.com/coder/claudecode.nvim) to bridge the gap where Claude Code CLI doesn't support direct image pasting like Cursor. 

With this integration:
- Take screenshots directly in Neovim using `macos-screenshot.nvim`
- Screenshots are automatically saved and paths copied to clipboard
- Paste the screenshot paths in Claude Code conversations
- Maintain seamless AI-assisted development workflow

Perfect complement for developers using Claude Code who need visual context sharing capabilities.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

If you encounter any issues or have feature requests, please:

1. Check the [health check](#-health-check) results
2. Enable [debug mode](#-debug-mode) to collect logs
3. [Open an issue](https://github.com/pittcat/macos-screenshot.nvim/issues) with detailed information

---

**Note**: This plugin only works on macOS and requires Screen Recording permission to function properly.