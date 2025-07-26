local M = {}

---Validate the options table obtained from merging defaults and user options
local function validate_config()
    local config = require("macos-screenshot.config")
    local log = require("macos-screenshot.logger")
    
    if not config.is_valid() then
        vim.health.error("Configuration is not valid")
        log.error("Health check: Invalid configuration")
        return false
    end
    
    local opts = config.get()
    
    local ok, err = pcall(function()
        vim.validate {
            save_path = { opts.save_path, "string" },
            filename_format = { opts.filename_format, "string" },
            include_cursor = { opts.include_cursor, "boolean" },
            play_sound = { opts.play_sound, "boolean" },
            copy_path_format = { opts.copy_path_format, "string" },
            monitor_screenshots = { opts.monitor_screenshots, "boolean" },
            log = { opts.log, "table" },
            keybindings = { opts.keybindings, "table" }
        }
    end)
    
    if not ok then
        vim.health.error("Invalid configuration options: " .. err)
        log.error("Health check: Invalid options", err)
        return false
    else
        vim.health.ok("Configuration options are valid")
        log.info("Health check: Configuration validated")
        return true
    end
end

---Check macOS environment and dependencies
local function check_macos_environment()
    local utils = require("macos-screenshot.utils")
    local log = require("macos-screenshot.logger")
    
    -- Check if running on macOS
    if utils.is_macos() then
        vim.health.ok("Running on macOS")
        log.info("Health check: macOS environment confirmed")
    else
        vim.health.error("Not running on macOS - this plugin requires macOS")
        log.error("Health check: Not running on macOS")
        return false
    end
    
    -- Check screencapture command availability
    if vim.fn.executable('screencapture') == 1 then
        vim.health.ok("screencapture command is available")
        log.info("Health check: screencapture command found")
    else
        vim.health.error("screencapture command not found")
        log.error("Health check: screencapture command missing")
        return false
    end
    
    -- Check Screen Recording permission
    local has_permission, error_msg = utils.check_screen_recording_permission()
    if has_permission then
        vim.health.ok("Screen Recording permission granted")
        log.info("Health check: Screen Recording permission OK")
    else
        vim.health.error("Screen Recording permission issue: " .. (error_msg or "Unknown error"))
        log.error("Health check: Screen Recording permission failed", error_msg)
        return false
    end
    
    return true
end

---Check save directory and permissions
local function check_save_directory()
    local config = require("macos-screenshot.config")
    local utils = require("macos-screenshot.utils")
    local log = require("macos-screenshot.logger")
    
    local opts = config.get()
    if not opts or not opts.save_path then
        vim.health.error("Save path not configured")
        return false
    end
    
    local save_path = vim.fn.expand(opts.save_path)
    
    -- Check if directory exists
    if vim.fn.isdirectory(save_path) == 1 then
        vim.health.ok("Save directory exists: " .. save_path)
        log.info("Health check: Save directory exists", save_path)
    else
        -- Try to create it
        if utils.ensure_directory(save_path) then
            vim.health.ok("Save directory created: " .. save_path)
            log.info("Health check: Save directory created", save_path)
        else
            vim.health.error("Cannot create save directory: " .. save_path)
            log.error("Health check: Cannot create save directory", save_path)
            return false
        end
    end
    
    -- Check write permissions
    local test_file = save_path .. "/.macos_screenshot_health_check"
    local file = io.open(test_file, "w")
    if file then
        file:write("health check test")
        file:close()
        os.remove(test_file)
        vim.health.ok("Save directory is writable")
        log.debug("Health check: Directory write permission OK")
    else
        vim.health.error("Cannot write to save directory: " .. save_path)
        log.error("Health check: Directory write permission failed")
        return false
    end
    
    return true
end

---Check clipboard functionality
local function check_clipboard()
    local clipboard = require("macos-screenshot.clipboard")
    local log = require("macos-screenshot.logger")
    
    -- Check pbcopy availability
    if clipboard.is_pbcopy_available() then
        vim.health.ok("pbcopy command is available")
        log.info("Health check: pbcopy available")
    else
        vim.health.warn("pbcopy command not found - will use builtin clipboard")
        log.warn("Health check: pbcopy not available, using fallback")
    end
    
    -- Test clipboard functionality
    local test_text = "macos-screenshot health check " .. os.time()
    local success = clipboard.copy_path_builtin(test_text)
    
    if success then
        local clipboard_content = clipboard.get_clipboard_content()
        if clipboard_content == test_text then
            vim.health.ok("Clipboard functionality works")
            log.info("Health check: Clipboard test passed")
        else
            vim.health.warn("Clipboard test failed - content mismatch")
            log.warn("Health check: Clipboard test content mismatch")
        end
    else
        vim.health.error("Clipboard functionality failed")
        log.error("Health check: Clipboard test failed")
        return false
    end
    
    return true
end

---Check logging system
local function check_logging()
    local log = require("macos-screenshot.logger")
    
    local test_success, test_err = pcall(function()
        log.info("Health check test log message")
        log.debug("Health check debug message")
        log.structured("info", "health_check", { test = true, timestamp = os.time() })
    end)
    
    if test_success then
        vim.health.ok("Logging system is working")
        log.debug("Health check: Logging system test passed")
    else
        vim.health.error("Logging system failed: " .. tostring(test_err))
        -- Can't log this error since logging failed
        return false
    end
    
    return true
end

---Check Neovim version compatibility
local function check_neovim_version()
    local log = require("macos-screenshot.logger")
    
    if vim.fn.has('nvim-0.10') == 1 then
        vim.health.ok("Neovim version >= 0.10 (using vim.system)")
        log.info("Health check: Neovim 0.10+ detected")
    elseif vim.fn.has('nvim-0.7') == 1 then
        vim.health.ok("Neovim version >= 0.7 (using jobstart fallback)")
        log.info("Health check: Neovim 0.7+ detected")
    else
        vim.health.error("Neovim version < 0.7 (unsupported)")
        log.error("Health check: Unsupported Neovim version")
        return false
    end
    
    return true
end

---Run comprehensive health check
---This function is called by `:checkhealth macos-screenshot` command
function M.check()
    vim.health.start("macos-screenshot.nvim health check")
    
    local log = require("macos-screenshot.logger")
    local all_checks_passed = true
    
    -- Check Neovim version first
    if not check_neovim_version() then
        all_checks_passed = false
    end
    
    -- Check macOS environment
    if not check_macos_environment() then
        all_checks_passed = false
        -- If macOS checks fail, skip other checks
        return
    end
    
    -- Check configuration
    if not validate_config() then
        all_checks_passed = false
    end
    
    -- Check save directory
    if not check_save_directory() then
        all_checks_passed = false
    end
    
    -- Check clipboard
    if not check_clipboard() then
        all_checks_passed = false
    end
    
    -- Check logging
    if not check_logging() then
        all_checks_passed = false
    end
    
    -- Check debug mode
    if log.is_debug_mode() then
        vim.health.info("Debug mode is enabled")
        vim.health.info("Debug log file: " .. log.get_debug_log_file())
        log.info("Health check: Debug mode enabled")
    else
        vim.health.info("Debug mode is disabled (use :ScreenshotDebugEnable to enable)")
    end
    
    -- Final summary
    if all_checks_passed then
        vim.health.ok("All health checks passed - plugin is ready to use")
    else
        vim.health.error("Some health checks failed - plugin may not work correctly")
    end
end

return M