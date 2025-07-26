local M = {}
local config = require('macos-screenshot.config')
local log = require('macos-screenshot.logger')

---Build screencapture command arguments
---@param opts MacosScreenshotCaptureOptions
---@return string[]
local function build_command(opts)
    local cmd = { "screencapture" }
    local cfg = config.get()
    
    -- 静音模式（无声音）
    if not cfg.play_sound then
        table.insert(cmd, "-x")
    end
    
    -- 包含光标
    if cfg.include_cursor then
        table.insert(cmd, "-C")
    end
    
    -- 截图类型特定参数
    if opts.type == "interactive" then
        table.insert(cmd, "-i")
    elseif opts.type == "full" then
        -- 全屏截图无需额外参数
    elseif opts.type == "window" then
        table.insert(cmd, "-w")
    elseif opts.type == "selection" then
        table.insert(cmd, "-s")
    elseif opts.type == "window_id" and opts.window_id then
        table.insert(cmd, "-l")
        table.insert(cmd, tostring(opts.window_id))
    end
    
    -- 输出文件
    table.insert(cmd, opts.output)
    
    log.debug("Built screencapture command:", table.concat(cmd, " "))
    return cmd
end

---Generate unique filename for screenshot
---@param base_name? string 基础文件名
---@return string 完整文件路径
local function generate_filepath(base_name)
    local cfg = config.get()
    local timestamp = os.date(cfg.filename_format)
    local filename
    
    if base_name then
        filename = string.format("%s_%s.png", base_name, timestamp)
    else
        filename = string.format("Screenshot_%s.png", timestamp)
    end
    
    local filepath = cfg.save_path .. "/" .. filename
    
    -- 确保文件名唯一
    local counter = 1
    local base_filepath = filepath
    while vim.fn.filereadable(filepath) == 1 do
        local name_without_ext = string.gsub(base_filepath, "%.png$", "")
        filepath = string.format("%s_%d.png", name_without_ext, counter)
        counter = counter + 1
    end
    
    return filepath
end

---Execute screenshot capture
---@param opts MacosScreenshotCaptureOptions
function M.capture(opts)
    if not opts or not opts.output then
        log.error("Invalid capture options provided")
        if opts.on_error then
            opts.on_error("Invalid capture options")
        end
        return
    end
    
    local cmd = build_command(opts)
    
    log.screenshot_action("start", {
        type = opts.type,
        output = opts.output,
        command = table.concat(cmd, " ")
    })
    
    -- 使用 vim.system 进行异步执行（Neovim 0.10+）
    if vim.system then
        vim.system(cmd, { 
            text = false,
            detach = true  -- Allow process to run independently
        }, function(result)
            if result.code == 0 then
                -- 延迟检查文件是否已创建（用户可能取消了操作）
                vim.defer_fn(function()
                    if vim.fn.filereadable(opts.output) == 1 then
                        log.screenshot_action("success", {
                            type = opts.type,
                            output = opts.output,
                            file_size = vim.fn.getfsize(opts.output)
                        })
                        
                        if opts.on_success then
                            opts.on_success(opts.output)
                        end
                    else
                        log.screenshot_action("cancelled", {
                            type = opts.type,
                            output = opts.output
                        })
                        
                        if opts.on_error then
                            opts.on_error("Screenshot was cancelled by user")
                        end
                    end
                end, 100)
            else
                local error_msg = result.stderr or "Unknown screencapture error"
                log.screenshot_error("command_failed", error_msg, {
                    type = opts.type,
                    exit_code = result.code,
                    command = table.concat(cmd, " ")
                })
                
                if opts.on_error then
                    opts.on_error(error_msg)
                end
            end
        end)
    else
        -- 旧版本 Neovim 的回退方案
        local job_id = vim.fn.jobstart(cmd, {
            detach = 1,  -- Allow process to run independently
            on_exit = function(_, exit_code)
                if exit_code == 0 then
                    vim.defer_fn(function()
                        if vim.fn.filereadable(opts.output) == 1 then
                            log.screenshot_action("success", {
                                type = opts.type,
                                output = opts.output
                            })
                            
                            if opts.on_success then
                                opts.on_success(opts.output)
                            end
                        else
                            log.screenshot_action("cancelled", {
                                type = opts.type,
                                output = opts.output
                            })
                            
                            if opts.on_error then
                                opts.on_error("Screenshot was cancelled by user")
                            end
                        end
                    end, 100)
                else
                    log.screenshot_error("command_failed", "screencapture command failed", {
                        type = opts.type,
                        exit_code = exit_code
                    })
                    
                    if opts.on_error then
                        opts.on_error("Screenshot command failed with exit code: " .. exit_code)
                    end
                end
            end,
            on_stderr = function(_, data)
                if data and #data > 0 then
                    local error_msg = table.concat(data, "\n")
                    log.screenshot_error("stderr", error_msg, { type = opts.type })
                end
            end
        })
        
        if job_id <= 0 then
            log.screenshot_error("job_start_failed", "Failed to start screencapture job", {
                type = opts.type,
                job_id = job_id
            })
            
            if opts.on_error then
                opts.on_error("Failed to start screencapture command")
            end
        end
    end
end

---Take screenshot with specified type
---@param capture_type? "interactive"|"full"|"window"|"selection" 截图类型
---@param base_name? string 基础文件名
---@param callback? fun(success: boolean, path_or_error: string) 完成回调
function M.take_screenshot(capture_type, base_name, callback)
    capture_type = capture_type or 'interactive'
    
    local filepath = generate_filepath(base_name)
    
    -- 确保目录存在
    local dir = vim.fn.fnamemodify(filepath, ":h")
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
    
    M.capture({
        type = capture_type,
        output = filepath,
        on_success = function(path)
            if callback then
                callback(true, path)
            end
        end,
        on_error = function(err)
            if callback then
                callback(false, err)
            end
        end
    })
end

---Check if screencapture command is available
---@return boolean
function M.is_available()
    return vim.fn.executable('screencapture') == 1
end

---Get supported capture types
---@return string[]
function M.get_capture_types()
    return { 'interactive', 'full', 'window', 'selection' }
end

return M