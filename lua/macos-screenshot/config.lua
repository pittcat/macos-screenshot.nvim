---@class Config
local M = {}

---@class MacosScreenshotConfig
local defaults = {
    save_path = "~/Desktop/Screenshots",
    filename_format = "%Y%m%d_%H%M%S",
    include_cursor = false,
    play_sound = false,
    copy_path_format = "absolute", -- "absolute", "relative", "home"
    monitor_screenshots = true,
    
    -- Log configuration
    log = {
        level = "info",           -- trace, debug, info, warn, error, fatal
        use_console = true,
        use_file = true,
        highlights = true,
        float_precision = 0.01
    },
    
    -- Debug mode configuration
    debug = {
        auto_enable = false,      -- Whether to auto-enable debug mode
        log_levels = {"trace", "debug", "info", "warn"},  -- Log levels for debug mode
        save_system_info = true   -- Whether to save system information
    },
    
    -- Keybinding configuration
    keybindings = {
        enabled = true,
        full_screen = "<leader>ss",     -- Window selection screenshot
        selection = "<leader>sp"        -- Selection screenshot (partial)
    }
}

---@type MacosScreenshotConfig
M.options = {}

---Setup configuration with validation
---@param opts MacosScreenshotConfig|nil User configuration
---@return MacosScreenshotConfig
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
    
    -- Configuration validation
    vim.validate {
        save_path = { M.options.save_path, "string" },
        filename_format = { M.options.filename_format, "string" },
        include_cursor = { M.options.include_cursor, "boolean" },
        play_sound = { M.options.play_sound, "boolean" },
        copy_path_format = { M.options.copy_path_format, "string" },
        monitor_screenshots = { M.options.monitor_screenshots, "boolean" },
        log = { M.options.log, "table" },
        debug = { M.options.debug, "table" },
        keybindings = { M.options.keybindings, "table" }
    }
    
    -- Validate copy_path_format value
    local valid_formats = { "absolute", "relative", "home" }
    if not vim.tbl_contains(valid_formats, M.options.copy_path_format) then
        error("Invalid copy_path_format. Must be one of: " .. table.concat(valid_formats, ", "))
    end
    
    -- Path processing
    M.options.save_path = vim.fn.expand(M.options.save_path)
    
    -- Ensure save directory exists
    if vim.fn.isdirectory(M.options.save_path) == 0 then
        vim.fn.mkdir(M.options.save_path, "p")
    end
    
    -- Auto-enable debug mode if configured
    if M.options.debug and M.options.debug.auto_enable then
        vim.defer_fn(function()
            local log = require('macos-screenshot.logger')
            log.enable_debug_mode()
            if M.options.debug.save_system_info then
                log.log_system_info()
            end
        end, 100)  -- Delay to ensure logger is loaded
    end
    
    return M.options
end

---Get current configuration
---@return MacosScreenshotConfig
function M.get()
    return M.options
end

---Check if configuration is valid
---@return boolean
function M.is_valid()
    return M.options and M.options.save_path and M.options.filename_format and true or false
end

return M