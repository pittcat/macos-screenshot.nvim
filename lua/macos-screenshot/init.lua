local M = {}

-- Module dependencies
local config = require('macos-screenshot.config')
local log = require('macos-screenshot.logger')
local screencapture = require('macos-screenshot.screencapture')
local clipboard = require('macos-screenshot.clipboard')
local utils = require('macos-screenshot.utils')

-- Plugin state
---@type MacosScreenshotState
local state = {
    initialized = false,
    active_jobs = {},
    last_screenshot = nil,
    monitor_job = nil
}

---Setup the macos-screenshot plugin
---@param opts MacosScreenshotConfig|nil User configuration options
---@return boolean success
function M.setup(opts)
    if state.initialized then
        return true
    end
    
    -- Verify macOS environment
    if not utils.is_macos() then
        local error_msg = "macos-screenshot.nvim can only run on macOS"
        log.error(error_msg)
        vim.notify(error_msg, vim.log.levels.ERROR, { title = "macOS Screenshot" })
        return false
    end
    
    -- Check screencapture command
    if not screencapture.is_available() then
        local error_msg = "screencapture command not found"
        log.error(error_msg)
        vim.notify(error_msg, vim.log.levels.ERROR, { title = "macOS Screenshot" })
        return false
    end
    
    -- Initialize configuration
    local success, err = pcall(function()
        config.setup(opts)
    end)
    
    if not success then
        log.error("Setup failed:", err)
        vim.notify("Plugin setup failed: " .. err, vim.log.levels.ERROR, { title = "macOS Screenshot" })
        return false
    end
    
    -- Check screen recording permission
    local has_permission, permission_error = utils.check_screen_recording_permission()
    if not has_permission then
        log.warn("Screen recording permission issue:", permission_error)
        vim.notify(
            permission_error or "Screen Recording permission may be required",
            vim.log.levels.WARN,
            { title = "macOS Screenshot" }
        )
    end
    
    -- Create user commands
    M._create_commands()
    
    -- Setup keybindings
    local cfg = config.get()
    if cfg.keybindings and cfg.keybindings.enabled then
        M._setup_keybindings()
    end
    
    state.initialized = true
    return true
end

---Create user commands
function M._create_commands()
    -- Main command: full screen screenshot
    vim.api.nvim_create_user_command('Screenshot', function()
        M.take_screenshot('full')
    end, { desc = 'Take full screen screenshot' })
    
    -- Main command: selection screenshot
    vim.api.nvim_create_user_command('ScreenshotSelect', function()
        M.take_screenshot('selection')
    end, { desc = 'Take selection screenshot' })
    
    -- Debug 相关命令
    vim.api.nvim_create_user_command('ScreenshotDebugEnable', function()
        log.enable_debug_mode()
        log.log_system_info()
    end, { desc = 'Enable debug mode' })
    
    vim.api.nvim_create_user_command('ScreenshotDebugDisable', function()
        log.disable_debug_mode()
    end, { desc = 'Disable debug mode' })
    
    vim.api.nvim_create_user_command('ScreenshotDebugLog', function()
        log.open_debug_log()
    end, { desc = 'Open debug log file' })
    
    vim.api.nvim_create_user_command('ScreenshotDebugTail', function(opts)
        local lines = tonumber(opts.args) or 20
        log.show_debug_tail(lines)
    end, { 
        nargs = '?',
        desc = 'Show last N lines of debug log' 
    })
    
    vim.api.nvim_create_user_command('ScreenshotDebugClear', function()
        log.clear_debug_log()
    end, { desc = 'Clear debug log' })
    
    vim.api.nvim_create_user_command('ScreenshotDebugInfo', function()
        local debug_info = {
            debug_mode = log.is_debug_mode(),
            debug_file = log.get_debug_log_file(),
            plugin_state = M.get_state(),
            plugin_config = M.get_config()
        }
        vim.notify("Debug Info:\n" .. vim.inspect(debug_info), vim.log.levels.INFO)
    end, { desc = 'Show debug information' })
end

---Setup keybindings
function M._setup_keybindings()
    local cfg = config.get()
    local keybindings = cfg.keybindings
    
    -- Full screen screenshot keybinding
    if keybindings.full_screen then
        vim.keymap.set('n', keybindings.full_screen, function()
            M.take_screenshot('full')
        end, { desc = 'Full screen screenshot', silent = true })
    end
    
    -- Selection screenshot keybinding
    if keybindings.selection then
        vim.keymap.set('n', keybindings.selection, function()
            M.take_screenshot('selection')
        end, { desc = 'Selection screenshot', silent = true })
    end
end

---Take screenshot with specified type
---@param capture_type? "interactive"|"full"|"window"|"selection" Screenshot type
---@param base_name? string Base filename (optional)
function M.take_screenshot(capture_type, base_name)
    if not state.initialized then
        log.error("Plugin not initialized - call setup() first")
        vim.notify("Plugin not initialized", vim.log.levels.ERROR, { title = "macOS Screenshot" })
        return
    end
    
    capture_type = capture_type or 'interactive'
    
    -- Simple status bar hint
    local action_text = capture_type == 'full' and 'Taking full screen screenshot...' or 'Please select screenshot area...'
    vim.cmd('echo "' .. action_text .. '"')
    
    log.screenshot_action("requested", {
        type = capture_type,
        base_name = base_name,
        timestamp = os.time()
    })
    
    screencapture.take_screenshot(capture_type, base_name, function(success, path_or_error)
        if success then
            state.last_screenshot = path_or_error
            
            -- Copy path to clipboard
            clipboard.copy_screenshot_path(path_or_error, function(clipboard_success)
                -- Simple completion hint
                local filename = vim.fn.fnamemodify(path_or_error, ':t')
                vim.schedule(function()
                    vim.cmd('echo "Screenshot completed: ' .. filename .. '. Path copied to clipboard"')
                end)
                
                log.screenshot_action("completed", {
                    type = capture_type,
                    path = path_or_error,
                    clipboard_success = clipboard_success,
                    file_info = utils.get_screenshot_info(path_or_error)
                })
            end)
        else
            log.screenshot_error("capture_failed", path_or_error, {
                type = capture_type,
                base_name = base_name
            })
            
            vim.schedule(function()
                vim.notify(
                    "Screenshot failed: " .. path_or_error,
                    vim.log.levels.ERROR,
                    { title = "macOS Screenshot" }
                )
            end)
        end
    end)
end

---Get last screenshot path
---@return string|nil
function M.get_last_screenshot()
    return state.last_screenshot
end

---Open last screenshot in default application
function M.open_last_screenshot()
    if not state.last_screenshot then
        vim.notify("No screenshot taken yet", vim.log.levels.WARN, { title = "macOS Screenshot" })
        return
    end
    
    if utils.open_file(state.last_screenshot) then
        log.info("Opened last screenshot:", state.last_screenshot)
    else
        vim.notify("Failed to open screenshot", vim.log.levels.ERROR, { title = "macOS Screenshot" })
    end
end

---Reveal last screenshot in Finder
function M.reveal_last_screenshot()
    if not state.last_screenshot then
        vim.notify("No screenshot taken yet", vim.log.levels.WARN, { title = "macOS Screenshot" })
        return
    end
    
    if utils.reveal_in_finder(state.last_screenshot) then
        log.info("Revealed last screenshot in Finder:", state.last_screenshot)
    else
        vim.notify("Failed to reveal screenshot in Finder", vim.log.levels.ERROR, { title = "macOS Screenshot" })
    end
end

---Show information about last screenshot
function M.show_last_screenshot_info()
    if not state.last_screenshot then
        vim.notify("No screenshot taken yet", vim.log.levels.WARN, { title = "macOS Screenshot" })
        return
    end
    
    local info = utils.get_screenshot_info(state.last_screenshot)
    if not info then
        vim.notify("Could not get screenshot info", vim.log.levels.ERROR, { title = "macOS Screenshot" })
        return
    end
    
    local message = string.format(
        "Screenshot Info:\nFile: %s\nSize: %s\nCreated: %s\nPath: %s",
        info.name,
        info.size_human,
        info.created_str,
        info.path
    )
    
    vim.notify(message, vim.log.levels.INFO, { title = "macOS Screenshot" })
end

---Check if plugin is initialized
---@return boolean
function M.is_initialized()
    return state.initialized
end

---Get plugin state (for debugging)
---@return MacosScreenshotState
function M.get_state()
    return vim.deepcopy(state)
end

---Get plugin configuration
---@return MacosScreenshotConfig
function M.get_config()
    return config.get()
end

-- Export log interface for users
M.log = log

return M