-- repro/repro.lua
-- Minimal configuration for reproducing issues

-- Add current directory to runtime path
vim.opt.runtimepath:prepend(vim.fn.getcwd())

-- Create temporary directory for testing
local test_dir = "/tmp/macos_screenshot_repro_" .. os.time()
vim.fn.mkdir(test_dir, "p")

-- Setup plugin with minimal configuration
require("macos-screenshot").setup({
    save_path = test_dir,
    filename_format = "%Y%m%d_%H%M%S",
    log = {
        level = "debug",
        use_console = true,
        use_file = false  -- Disable file logging for repro
    },
    keybindings = {
        enabled = true,
        screenshot = "<leader>ss",
        full_screen = "<leader>sf",
        window = "<leader>sw",
        selection = "<leader>sr"
    }
})

-- Print helpful information
print("🔧 macos-screenshot.nvim reproduction environment loaded")
print("📂 Test directory: " .. test_dir)
print("🎯 Available commands:")
print("   :Screenshot                 - Interactive screenshot")
print("   :ScreenshotFull            - Full screen screenshot")
print("   :ScreenshotWindow          - Window screenshot")
print("   :ScreenshotSelection       - Selection screenshot")
print("   :checkhealth macos-screenshot - Run health check")
print("🔗 Available keybindings:")
print("   <leader>ss - Interactive screenshot")
print("   <leader>sf - Full screen screenshot")
print("   <leader>sw - Window screenshot")
print("   <leader>sr - Selection screenshot")
print("")
print("💡 To test: Try :Screenshot or use <leader>ss")
print("🩺 Health check: :checkhealth macos-screenshot")

-- Set leader key for testing if not set
if vim.g.mapleader == nil then
    vim.g.mapleader = " "
    print("🔑 Leader key set to <Space> for testing")
end