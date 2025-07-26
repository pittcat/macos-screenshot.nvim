-- repro/debug.lua
-- Debug mode reproduction environment

-- Debug mode will be enabled via configuration

-- Add current directory to runtime path
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- Create temporary directory for testing
local test_dir = "/tmp/macos_screenshot_debug_" .. os.time()
vim.fn.mkdir(test_dir, "p")

-- Setup plugin with debug configuration
require("macos-screenshot").setup({
    save_path = test_dir,
    filename_format = "%Y%m%d_%H%M%S",
    log = {
        level = "debug",
        use_console = true,
        use_file = true
    },
    debug = {
        auto_enable = true,       -- 自动启用 debug 模式
        log_levels = {"trace", "debug", "info", "warn"},
        save_system_info = true
    },
    keybindings = {
        enabled = true,
        full_screen = "<leader>ss",
        selection = "<leader>sr"
    }
})

-- Get logger instance
local log = require("macos-screenshot").log

-- Print debug information
print("🐛 macos-screenshot.nvim DEBUG MODE")
print("=" .. string.rep("=", 40))
print("📂 Test directory: " .. test_dir)
print("🐛 Debug mode: " .. tostring(log.is_debug_mode()))
print("📝 Debug log file: " .. log.get_debug_log_file())
print("=" .. string.rep("=", 40))
print("")

print("🎯 Available commands:")
print("   :Screenshot                - Full screen screenshot")
print("   :ScreenshotSelect          - Selection screenshot")
print("   :checkhealth macos-screenshot - Run health check")
print("")

print("🐛 Debug commands:")
print("   :ScreenshotDebugEnable     - Enable debug mode")
print("   :ScreenshotDebugDisable    - Disable debug mode")
print("   :ScreenshotDebugLog        - Open debug log file")
print("   :ScreenshotDebugTail [N]   - Show last N lines of debug log")
print("   :ScreenshotDebugClear      - Clear debug log")
print("   :ScreenshotDebugInfo       - Show debug information")
print("")

print("🔗 Available keybindings:")
print("   <leader>ss - Full screen screenshot")
print("   <leader>sr - Selection screenshot")
print("")

print("💡 Debug workflow:")
print("   1. Debug mode auto-enabled in this test")
print("   2. Try taking a screenshot: :Screenshot")
print("   3. Check debug log: :ScreenshotDebugTail")
print("   4. Open full debug log: :ScreenshotDebugLog")
print("   5. Clear log for new test: :ScreenshotDebugClear")
print("")

-- Set leader key for testing if not set
if vim.g.mapleader == nil then
    vim.g.mapleader = " "
    print("🔑 Leader key set to <Space> for testing")
end

-- Add some test debug messages
log.debug("Debug environment initialized successfully")
log.info("Ready for debug testing!")

print("")
print("🚀 Debug environment ready! Try :Screenshot or <leader>ss")