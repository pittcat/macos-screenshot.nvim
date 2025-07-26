-- lua/macos-screenshot/logger.lua
-- macOS Screenshot Plugin Logger System Wrapper

-- Simple logger implementation to avoid vlog complexity
local M = {}

-- Debug mode state (controlled by commands)
local is_debug_mode = false

-- Debug log file path (fixed filename, directly use /tmp)
local debug_log_file = "/tmp/macos-screenshot-debug.log"

-- Get configuration options
local function get_log_config()
    local ok, config = pcall(require, 'macos-screenshot.config')
    if ok and config.options and config.options.log then
        return config.options.log
    else
        -- Return default configuration
        return {
            level = "info",
            use_console = true,
            use_file = is_debug_mode,  -- Debug 模式下启用文件输出
            highlights = true
        }
    end
end

-- 初始化 debug 日志文件 (清空上一次的内容)
local function init_debug_log()
    if is_debug_mode then
        local file = io.open(debug_log_file, "w")
        if file then
            local config = get_log_config()
            file:write(string.format(
                "=== macos-screenshot.nvim Debug Log ===\n" ..
                "Start Time: %s\n" ..
                "Debug Mode: %s\n" ..
                "Log Level: %s\n" ..
                "Log File: %s\n" ..
                "========================================\n\n",
                os.date("%Y-%m-%d %H:%M:%S"),
                tostring(is_debug_mode),
                config.level or "info",
                debug_log_file
            ))
            file:close()
        end
    end
end

-- 日志级别映射
local levels = {
    trace = 1,
    debug = 2,
    info = 3,
    warn = 4,
    error = 5,
    fatal = 6
}

-- 高亮配置
local highlights = {
    trace = "Comment",
    debug = "Comment", 
    info = "Directory",
    warn = "WarningMsg",
    error = "ErrorMsg",
    fatal = "ErrorMsg"
}

-- Get current configuration (lazy initialization)
local config = nil
local current_level = nil

-- Initialize configuration
local function init_config()
    if not config then
        config = get_log_config()
        current_level = levels[config.level] or levels.info
    end
end

-- 写入 debug 日志文件
local function write_to_debug_file(level, message)
    if is_debug_mode then
        local file = io.open(debug_log_file, "a")
        if file then
            local timestamp = os.date("%H:%M:%S.%3N")
            local log_line = string.format("[%s] [%s] %s\n", timestamp, level:upper(), message)
            file:write(log_line)
            file:close()
        end
    end
end

-- 通用日志函数
local function log_message(level, ...)
    init_config()
    local level_num = levels[level]
    if not level_num or level_num < current_level then
        return
    end
    
    -- 格式化消息
    local args = {...}
    local msg_parts = {}
    for i, v in ipairs(args) do
        if type(v) == "table" then
            table.insert(msg_parts, vim.inspect(v))
        else
            table.insert(msg_parts, tostring(v))
        end
    end
    local message = table.concat(msg_parts, " ")
    
    -- 写入 debug 文件
    write_to_debug_file(level, message)
    
    -- 输出到控制台
    if config.use_console then
        -- 在异步上下文中使用 vim.schedule 确保安全
        vim.schedule(function()
            local prefix = string.format("[%s] [macos-screenshot] ", level:upper())
            
            if config.highlights and highlights[level] then
                vim.cmd(string.format("echohl %s", highlights[level]))
            end
            
            -- 分行输出
            local lines = vim.split(message, "\n")
            for _, line in ipairs(lines) do
                vim.cmd(string.format('echom "%s%s"', prefix, vim.fn.escape(line, '"')))
            end
            
            if config.highlights and highlights[level] then
                vim.cmd("echohl NONE")
            end
        end)
    end
end

-- 创建各个级别的日志函数
for level_name, _ in pairs(levels) do
    M[level_name] = function(...)
        log_message(level_name, ...)
    end
end

-- 添加结构化日志支持
---@param level string 日志级别
---@param event string 事件名称
---@param data table 事件数据
function M.structured(level, event, data)
    local msg = string.format("[%s] %s", event, vim.inspect(data))
    M[level](msg)
end

-- 添加条件日志支持（生产环境优化）
local is_debug = vim.env.NODE_ENV ~= "production"

local original_trace = M.trace
local original_debug = M.debug

function M.trace(...)
    if is_debug then
        original_trace(...)
    end
end

function M.debug(...)
    if is_debug then
        original_debug(...)
    end
end

-- 添加方便的截图专用日志方法
---@param action string 截图动作
---@param details table 详细信息
function M.screenshot_action(action, details)
    -- 只在 debug 模式下输出结构化日志
    if is_debug_mode then
        M.structured("info", "screenshot_" .. action, details)
    end
end

---@param error_type string 错误类型
---@param error_msg string 错误消息
---@param context table|nil 上下文信息
function M.screenshot_error(error_type, error_msg, context)
    local data = {
        type = error_type,
        message = error_msg,
        context = context or {}
    }
    -- 只在 debug 模式下输出结构化日志
    if is_debug_mode then
        M.structured("error", "screenshot_error", data)
    else
        -- 非 debug 模式下只显示简单错误
        M.error(error_msg)
    end
end

-- Debug 模式相关功能
---检查是否为 debug 模式
---@return boolean
function M.is_debug_mode()
    return is_debug_mode
end

---启用 debug 模式
function M.enable_debug_mode()
    is_debug_mode = true
    -- 重新初始化配置，确保 use_file 被设置
    config = nil
    init_config()
    if config then
        config.use_file = true
    end
    init_debug_log()
    vim.notify("Debug mode enabled - logs: " .. debug_log_file, vim.log.levels.INFO)
end

---禁用 debug 模式
function M.disable_debug_mode()
    is_debug_mode = false
    vim.notify("Debug mode disabled", vim.log.levels.INFO)
end

---获取 debug 日志文件路径
---@return string
function M.get_debug_log_file()
    return debug_log_file
end

---打开 debug 日志文件查看
function M.open_debug_log()
    if is_debug_mode then
        vim.cmd("edit " .. vim.fn.fnameescape(debug_log_file))
    else
        vim.notify("Debug mode is not enabled. Use :ScreenshotDebugEnable to enable it", vim.log.levels.WARN)
    end
end

---显示 debug 日志文件的最后几行
---@param lines? number 显示的行数，默认 20
function M.show_debug_tail(lines)
    lines = lines or 20
    if is_debug_mode then
        if vim.fn.filereadable(debug_log_file) == 1 then
            local result = vim.fn.system(string.format("tail -%d %s", lines, vim.fn.shellescape(debug_log_file)))
            vim.notify("Debug Log (last " .. lines .. " lines):\n" .. result, vim.log.levels.INFO)
        else
            vim.notify("Debug log file not found: " .. debug_log_file, vim.log.levels.WARN)
        end
    else
        vim.notify("Debug mode is not enabled", vim.log.levels.WARN)
    end
end

---清空 debug 日志文件
function M.clear_debug_log()
    if is_debug_mode then
        init_debug_log()  -- 重新初始化会清空文件
        M.info("Debug log cleared")
    else
        vim.notify("Debug mode is not enabled", vim.log.levels.WARN)
    end
end

---记录系统环境信息 (用于 debug)
function M.log_system_info()
    if not is_debug_mode then
        return
    end
    
    local info = {
        "=== System Information ===",
        "OS: " .. vim.loop.os_uname().sysname .. " " .. vim.loop.os_uname().version,
        "Neovim version: " .. vim.inspect(vim.version()),
        "Current working directory: " .. vim.fn.getcwd(),
        "Plugin directory: " .. debug.getinfo(1, "S").source:sub(2):match("(.*/)") or "unknown",
        "TMPDIR: " .. (os.getenv("TMPDIR") or "not set"),
        "Debug mode: " .. tostring(is_debug_mode),
        "Debug log file: " .. debug_log_file,
        "==========================="
    }
    
    for _, line in ipairs(info) do
        write_to_debug_file("DEBUG", line)
    end
end

-- 不在模块加载时自动记录系统信息，由用户显式启用 debug 模式时再记录

return M