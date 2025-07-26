local M = {}
local config = require('macos-screenshot.config')
local log = require('macos-screenshot.logger')

---Format path according to configuration
---@param path string 原始路径
---@return string 格式化后的路径
local function format_path(path)
    local cfg = config.get()
    local format = cfg.copy_path_format
    
    if format == "relative" then
        -- 获取相对于当前目录的路径
        local cwd = vim.fn.getcwd()
        if vim.startswith(path, cwd) then
            local relative_path = vim.fn.fnamemodify(path, ":.")
            log.debug("Formatted path to relative:", relative_path)
            return relative_path
        end
    elseif format == "home" then
        -- 用 ~ 替换家目录
        local home = vim.fn.expand("~")
        if vim.startswith(path, home) then
            local home_path = "~" .. string.sub(path, #home + 1)
            log.debug("Formatted path to home:", home_path)
            return home_path
        end
    end
    
    -- "absolute" 返回原始路径
    log.debug("Using absolute path:", path)
    return path
end

---Copy path to system clipboard using pbcopy
---@param path string 文件路径
---@param callback? fun(success: boolean) 完成回调
function M.copy_path(path, callback)
    if not path or path == "" then
        log.error("Empty path provided to copy_path")
        if callback then callback(false) end
        return
    end
    
    local formatted_path = format_path(path)
    
    log.debug("Copying path to clipboard:", formatted_path)
    
    -- 使用 pbcopy 复制到系统剪切板
    local cmd = { "pbcopy" }
    
    if vim.system then
        -- Neovim 0.10+ 使用 vim.system
        vim.system(cmd, { 
            stdin = formatted_path,
            text = true 
        }, function(result)
            local success = result.code == 0
            
            if not success then
                log.error("Failed to copy path to clipboard:", result.stderr or "Unknown error")
            end
            
            if callback then
                callback(success)
            end
        end)
    else
        -- 旧版本 Neovim 回退方案
        local job_id = vim.fn.jobstart(cmd, {
            stdin = "pipe",
            on_exit = function(_, exit_code)
                local success = exit_code == 0
                
                if not success then
                    log.error("Failed to copy path to clipboard, exit code:", exit_code)
                end
                
                if callback then
                    callback(success)
                end
            end
        })
        
        if job_id > 0 then
            vim.fn.chansend(job_id, formatted_path)
            vim.fn.chanclose(job_id, "stdin")
        else
            log.error("Failed to start pbcopy job")
            if callback then
                callback(false)
            end
        end
    end
end

---Copy path using Neovim's built-in clipboard (fallback method)
---@param path string 文件路径
---@return boolean success
function M.copy_path_builtin(path)
    if not path or path == "" then
        log.error("Empty path provided to copy_path_builtin")
        return false
    end
    
    local formatted_path = format_path(path)
    
    local success, err = pcall(function()
        vim.fn.setreg("+", formatted_path)
    end)
    
    if success then
        return true
    else
        log.error("Failed to copy path using builtin clipboard:", err)
        return false
    end
end

---Copy path with automatic fallback
---@param path string 文件路径
---@param callback? fun(success: boolean) 完成回调
function M.copy_path_with_fallback(path, callback)
    -- 首先尝试 pbcopy
    M.copy_path(path, function(success)
        if success then
            if callback then callback(true) end
        else
            -- 如果 pbcopy 失败，回退到内置剪切板
            log.warn("pbcopy failed, falling back to builtin clipboard")
            local builtin_success = M.copy_path_builtin(path)
            if callback then callback(builtin_success) end
        end
    end)
end

---Check if pbcopy is available
---@return boolean
function M.is_pbcopy_available()
    return vim.fn.executable('pbcopy') == 1
end

---Get current clipboard content (for testing)
---@return string|nil
function M.get_clipboard_content()
    local success, content = pcall(function()
        return vim.fn.getreg("+")
    end)
    
    if success then
        return content
    else
        return nil
    end
end

---Copy screenshot path and show notification
---@param path string 截图文件路径
---@param callback? fun(success: boolean) 完成回调
function M.copy_screenshot_path(path, callback)
    M.copy_path_with_fallback(path, function(success)
        if success then
            local formatted_path = format_path(path)
            vim.schedule(function()
                vim.notify(
                    string.format("Screenshot saved and path copied: %s", formatted_path),
                    vim.log.levels.INFO,
                    { title = "macOS Screenshot" }
                )
            end)
        else
            vim.schedule(function()
                vim.notify(
                    "Screenshot saved but failed to copy path to clipboard",
                    vim.log.levels.WARN,
                    { title = "macOS Screenshot" }
                )
            end)
        end
        
        if callback then
            callback(success)
        end
    end)
end

return M