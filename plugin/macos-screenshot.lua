-- plugin/macos-screenshot.lua
-- macOS Screenshot Plugin entry point

-- Prevent loading twice
if vim.g.loaded_macos_screenshot == 1 then
    return
end
vim.g.loaded_macos_screenshot = 1

-- Check Neovim version requirement
if vim.fn.has("nvim-0.7") == 0 then
    vim.api.nvim_err_writeln("macos-screenshot.nvim requires Neovim 0.7+")
    return
end

-- Only load on macOS
if vim.loop.os_uname().sysname ~= "Darwin" then
    return
end

-- Create a simple setup command for users who don't call setup() manually
vim.api.nvim_create_user_command("MacosScreenshotSetup", function(opts)
    local setup_opts = {}
    
    -- Parse simple key=value arguments
    if opts.args and opts.args ~= "" then
        for arg in opts.args:gmatch("%S+") do
            local key, value = arg:match("([^=]+)=([^=]+)")
            if key and value then
                -- Simple boolean parsing
                if value == "true" then
                    value = true
                elseif value == "false" then
                    value = false
                end
                setup_opts[key] = value
            end
        end
    end
    
    require("macos-screenshot").setup(setup_opts)
end, {
    nargs = "*",
    desc = "Setup macOS Screenshot plugin with basic options (key=value format)"
})

-- Auto-setup with defaults if no manual setup is called after VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Delay to allow user's init.lua to run first
        vim.defer_fn(function()
            local ok, screenshot = pcall(require, "macos-screenshot")
            if ok and not screenshot.is_initialized() then
                -- Only auto-setup if user hasn't called setup() manually
                screenshot.setup()
            end
        end, 100)
    end,
    once = true,
    desc = "Auto-setup macOS Screenshot plugin if not manually configured"
})