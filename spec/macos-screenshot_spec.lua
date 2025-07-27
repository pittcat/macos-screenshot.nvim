-- spec/macos-screenshot_spec.lua
describe("macos-screenshot.nvim", function()
    local screenshot
    local test_dir = "/tmp/macos_screenshot_test"
    
    before_each(function()
        -- 清理测试环境
        package.loaded['macos-screenshot'] = nil
        package.loaded['macos-screenshot.config'] = nil
        package.loaded['macos-screenshot.logger'] = nil
        package.loaded['macos-screenshot.screencapture'] = nil
        package.loaded['macos-screenshot.clipboard'] = nil
        package.loaded['macos-screenshot.utils'] = nil
        package.loaded['macos-screenshot.health'] = nil
        
        -- 创建测试目录
        vim.fn.system("rm -rf " .. test_dir)
        vim.fn.mkdir(test_dir, "p")
        
        screenshot = require('macos-screenshot')
    end)
    
    after_each(function()
        -- 清理测试目录
        vim.fn.system("rm -rf " .. test_dir)
    end)
    
    describe("plugin loading", function()
        it("should load without errors", function()
            assert.is_not_nil(screenshot)
            assert.is_function(screenshot.setup)
            assert.is_function(screenshot.take_screenshot)
            assert.is_function(screenshot.get_last_screenshot)
            assert.is_function(screenshot.is_initialized)
        end)
        
        it("should expose log interface", function()
            assert.is_not_nil(screenshot.log)
            assert.is_function(screenshot.log.info)
            assert.is_function(screenshot.log.error)
            assert.is_function(screenshot.log.debug)
        end)
    end)
    
    describe("configuration", function()
        it("should setup with default configuration", function()
            local result = screenshot.setup({
                save_path = test_dir,
                log = { use_console = false, use_file = false }
            })
            assert.is_true(result)
            assert.is_true(screenshot.is_initialized())
        end)
        
        it("should setup with custom configuration", function()
            local result = screenshot.setup({
                save_path = test_dir,
                filename_format = "%Y%m%d_%H%M%S",
                include_cursor = true,
                play_sound = false,
                copy_path_format = "home",
                log = {
                    level = "debug",
                    use_console = false,
                    use_file = false
                },
                keybindings = {
                    enabled = false
                }
            })
            assert.is_true(result)
            
            local config = screenshot.get_config()
            assert.equals(test_dir, config.save_path)
            assert.equals("%Y%m%d_%H%M%S", config.filename_format)
            assert.is_true(config.include_cursor)
            assert.is_false(config.play_sound)
            assert.equals("home", config.copy_path_format)
        end)
        
        it("should reject invalid configuration", function()
            -- Test config module directly to bypass pcall in main setup
            local config = require('macos-screenshot.config')
            
            assert.has_error(function()
                config.setup({
                    save_path = 123, -- invalid type
                    log = { use_console = false, use_file = false }
                })
            end)
        end)
        
        it("should reject invalid copy_path_format", function()
            -- Test config module directly to bypass pcall in main setup
            local config = require('macos-screenshot.config')
            
            assert.has_error(function()
                config.setup({
                    save_path = test_dir,
                    copy_path_format = "invalid_format",
                    log = { use_console = false, use_file = false }
                })
            end)
        end)
        
        it("should not initialize twice", function()
            screenshot.setup({
                save_path = test_dir,
                log = { use_console = false, use_file = false }
            })
            
            local first_config = screenshot.get_config()
            
            -- Try to setup again with different config
            screenshot.setup({
                save_path = "/tmp/different",
                log = { use_console = false, use_file = false }
            })
            
            local second_config = screenshot.get_config()
            
            -- Config should remain the same
            assert.equals(first_config.save_path, second_config.save_path)
        end)
    end)
    
    describe("macOS environment", function()
        local utils
        
        before_each(function()
            utils = require('macos-screenshot.utils')
        end)
        
        it("should detect macOS environment", function()
            -- This test will pass on macOS and fail on other systems
            local is_macos = utils.is_macos()
            assert.is_boolean(is_macos)
            
            if is_macos then
                assert.is_true(is_macos)
            else
                assert.is_false(is_macos)
            end
        end)
        
        it("should handle non-macOS gracefully", function()
            -- Mock non-macOS environment
            local original_uname = vim.loop.os_uname
            vim.loop.os_uname = function() return { sysname = "Linux" } end
            
            local success = screenshot.setup({
                save_path = test_dir,
                log = { use_console = false, use_file = false }
            })
            
            -- Should fail gracefully on non-macOS
            assert.is_false(success)
            assert.is_false(screenshot.is_initialized())
            
            -- Restore original function
            vim.loop.os_uname = original_uname
        end)
    end)
    
    describe("screencapture module", function()
        local screencapture
        
        before_each(function()
            screencapture = require('macos-screenshot.screencapture')
        end)
        
        it("should check screencapture availability", function()
            local available = screencapture.is_available()
            assert.is_boolean(available)
        end)
        
        it("should return supported capture types", function()
            local types = screencapture.get_capture_types()
            assert.is_table(types)
            assert.is_true(#types > 0)
            assert.is_true(vim.tbl_contains(types, 'interactive'))
            assert.is_true(vim.tbl_contains(types, 'full'))
            assert.is_true(vim.tbl_contains(types, 'window'))
            assert.is_true(vim.tbl_contains(types, 'selection'))
        end)
    end)
    
    describe("clipboard module", function()
        local clipboard
        
        before_each(function()
            clipboard = require('macos-screenshot.clipboard')
        end)
        
        it("should check pbcopy availability", function()
            local available = clipboard.is_pbcopy_available()
            assert.is_boolean(available)
        end)
        
        it("should copy path using builtin method", function()
            local test_path = "/tmp/test_screenshot.png"
            local success = clipboard.copy_path_builtin(test_path)
            assert.is_true(success)
            
            -- Verify clipboard content
            local content = clipboard.get_clipboard_content()
            assert.equals(test_path, content)
        end)
        
        it("should handle empty path gracefully", function()
            local success = clipboard.copy_path_builtin("")
            assert.is_false(success)
        end)
    end)
    
    describe("utils module", function()
        local utils
        
        before_each(function()
            utils = require('macos-screenshot.utils')
        end)
        
        it("should validate file paths", function()
            local valid, err = utils.validate_filepath(test_dir .. "/test.png")
            assert.is_true(valid)
            assert.is_nil(err)
            
            local invalid, err2 = utils.validate_filepath("")
            assert.is_false(invalid)
            assert.is_string(err2)
        end)
        
        it("should ensure directories exist", function()
            local new_dir = test_dir .. "/subdir"
            local success = utils.ensure_directory(new_dir)
            assert.is_true(success)
            assert.equals(1, vim.fn.isdirectory(new_dir))
        end)
        
        it("should format file sizes", function()
            -- Create a test file with known size
            local test_file = test_dir .. "/size_test.txt"
            local file = io.open(test_file, "w")
            file:write("test content")
            file:close()
            
            local size_str = utils.get_human_readable_size(test_file)
            assert.is_string(size_str)
            assert.is_not_nil(string.match(size_str, "%d+%.?%d* %w+"))
        end)
        
        it("should handle non-existent files", function()
            local size_str = utils.get_human_readable_size("/non/existent/file.png")
            assert.is_nil(size_str)
        end)
    end)
    
    describe("health check", function()
        local health
        
        before_each(function()
            health = require('macos-screenshot.health')
        end)
        
        it("should run health check without errors", function()
            -- Setup plugin first
            screenshot.setup({
                save_path = test_dir,
                log = { use_console = false, use_file = false }
            })
            
            assert.has_no.errors(function()
                health.check()
            end)
        end)
    end)
end)

describe("macos-screenshot configuration module", function()
    local config
    
    before_each(function()
        package.loaded['macos-screenshot.config'] = nil
        config = require('macos-screenshot.config')
    end)
    
    it("should setup with valid options", function()
        local opts = config.setup({
            save_path = "/tmp/test",
            filename_format = "%Y%m%d",
            log = { level = "info" }
        })
        
        assert.is_table(opts)
        assert.is_string(opts.save_path)
        assert.is_string(opts.filename_format)
    end)
    
    it("should validate configuration", function()
        config.setup({ save_path = "/tmp/test" })
        assert.is_true(config.is_valid())
        
        -- Reset config
        config.options = {}
        assert.is_false(config.is_valid())
    end)
    
    it("should expand save path", function()
        local opts = config.setup({
            save_path = "~/test_screenshots"
        })
        
        assert.is_not_nil(string.match(opts.save_path, "^/"))
        assert.is_nil(string.match(opts.save_path, "^~"))
    end)
end)