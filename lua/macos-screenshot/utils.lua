local M = {}
local log = require('macos-screenshot.logger')

---Check if running on macOS
---@return boolean
function M.is_macos()
    return vim.loop.os_uname().sysname == "Darwin"
end

---Check macOS Screen Recording permission
---@return boolean, string|nil has_permission, error_message
function M.check_screen_recording_permission()
    if not M.is_macos() then
        return false, "Not running on macOS"
    end
    
    -- 创建临时文件路径
    local test_file = "/tmp/macos_screenshot_permission_test.png"
    
    -- 尝试执行无声截图测试
    local result = vim.fn.system("screencapture -x " .. test_file .. " 2>&1")
    
    -- 检查是否提示需要屏幕录制权限
    if string.match(result, "Screen Recording") then
        return false, "Screen Recording permission is required. Please grant permission in System Preferences > Security & Privacy > Privacy > Screen Recording"
    end
    
    -- 清理测试文件
    vim.fn.delete(test_file)
    
    -- 检查命令是否执行成功
    if vim.v.shell_error == 0 then
        return true, nil
    else
        return false, "screencapture command failed: " .. result
    end
end

---Get active window ID using AppleScript
---@return number|nil window_id
function M.get_active_window_id()
    if not M.is_macos() then
        log.warn("get_active_window_id called on non-macOS system")
        return nil
    end
    
    local script = [[
        tell application "System Events"
            set frontApp to name of first application process whose frontmost is true
        end tell
        
        tell application frontApp
            if (count windows) > 0 then
                return id of window 1
            else
                return ""
            end if
        end tell
    ]]
    
    local result = vim.fn.system("osascript -e '" .. script .. "'")
    local window_id = tonumber(vim.trim(result))
    
    if window_id then
        log.debug("Active window ID:", window_id)
        return window_id
    else
        log.debug("Could not get active window ID")
        return nil
    end
end

---Open file in macOS Preview app
---@param filepath string 文件路径
---@return boolean success
function M.open_in_preview(filepath)
    if not M.is_macos() then
        log.warn("open_in_preview called on non-macOS system")
        return false
    end
    
    if vim.fn.filereadable(filepath) == 0 then
        log.error("File does not exist:", filepath)
        return false
    end
    
    local cmd = { "open", "-a", "Preview", filepath }
    local job_id = vim.fn.jobstart(cmd, {
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                log.debug("Successfully opened file in Preview:", filepath)
            else
                log.error("Failed to open file in Preview:", filepath)
            end
        end
    })
    
    return job_id > 0
end

---Open file in default application
---@param filepath string 文件路径
---@return boolean success
function M.open_file(filepath)
    if not M.is_macos() then
        log.warn("open_file called on non-macOS system")
        return false
    end
    
    if vim.fn.filereadable(filepath) == 0 then
        log.error("File does not exist:", filepath)
        return false
    end
    
    local cmd = { "open", filepath }
    local job_id = vim.fn.jobstart(cmd, {
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                log.debug("Successfully opened file:", filepath)
            else
                log.error("Failed to open file:", filepath)
            end
        end
    })
    
    return job_id > 0
end

---Reveal file in Finder
---@param filepath string 文件路径
---@return boolean success
function M.reveal_in_finder(filepath)
    if not M.is_macos() then
        log.warn("reveal_in_finder called on non-macOS system")
        return false
    end
    
    if vim.fn.filereadable(filepath) == 0 then
        log.error("File does not exist:", filepath)
        return false
    end
    
    local cmd = { "open", "-R", filepath }
    local job_id = vim.fn.jobstart(cmd, {
        on_exit = function(_, exit_code)
            if exit_code == 0 then
                log.debug("Successfully revealed file in Finder:", filepath)
            else
                log.error("Failed to reveal file in Finder:", filepath)
            end
        end
    })
    
    return job_id > 0
end

---Get file size in human readable format
---@param filepath string 文件路径
---@return string|nil size_string
function M.get_human_readable_size(filepath)
    local size = vim.fn.getfsize(filepath)
    if size < 0 then
        return nil
    end
    
    if size == 0 then
        return "0 B"
    end
    
    local units = { "B", "KB", "MB", "GB", "TB" }
    local unit_index = 1
    local size_float = size
    
    while size_float >= 1024 and unit_index < #units do
        size_float = size_float / 1024
        unit_index = unit_index + 1
    end
    
    if unit_index == 1 then
        return string.format("%d %s", size_float, units[unit_index])
    else
        return string.format("%.1f %s", size_float, units[unit_index])
    end
end

---Validate file path
---@param filepath string 文件路径
---@return boolean is_valid
---@return string|nil error_message
function M.validate_filepath(filepath)
    if not filepath or filepath == "" then
        return false, "Empty file path"
    end
    
    -- 检查路径长度
    if #filepath > 255 then
        return false, "File path too long"
    end
    
    -- 检查是否包含无效字符（对于 macOS）
    local invalid_chars = { "\0" }
    for _, char in ipairs(invalid_chars) do
        if string.find(filepath, char) then
            return false, "File path contains invalid character: " .. char
        end
    end
    
    -- 检查目录是否存在
    local dir = vim.fn.fnamemodify(filepath, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        return false, "Directory does not exist: " .. dir
    end
    
    return true, nil
end

---Create directory if it doesn't exist
---@param dir_path string 目录路径
---@return boolean success
function M.ensure_directory(dir_path)
    if vim.fn.isdirectory(dir_path) == 1 then
        return true
    end
    
    local success = vim.fn.mkdir(dir_path, "p") == 1
    if success then
        log.debug("Created directory:", dir_path)
    else
        log.error("Failed to create directory:", dir_path)
    end
    
    return success
end

---Get screenshot file info
---@param filepath string 截图文件路径
---@return table|nil file_info
function M.get_screenshot_info(filepath)
    if vim.fn.filereadable(filepath) == 0 then
        return nil
    end
    
    local stat = vim.loop.fs_stat(filepath)
    if not stat then
        return nil
    end
    
    return {
        path = filepath,
        name = vim.fn.fnamemodify(filepath, ":t"),
        size = stat.size,
        size_human = M.get_human_readable_size(filepath),
        created = stat.birthtime.sec,
        modified = stat.mtime.sec,
        created_str = os.date("%Y-%m-%d %H:%M:%S", stat.birthtime.sec),
        modified_str = os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec)
    }
end

return M