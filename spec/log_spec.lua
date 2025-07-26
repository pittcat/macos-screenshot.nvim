-- spec/log_spec.lua
describe("macos-screenshot logging", function()
    local log
    
    before_each(function()
        package.loaded['macos-screenshot.log'] = nil
        package.loaded['macos-screenshot.logger'] = nil
        
        -- Set test environment
        vim.env.MACOS_SCREENSHOT_LOG_LEVEL = "debug"
        vim.env.NODE_ENV = "test"
        
        log = require('macos-screenshot.logger')
    end)
    
    after_each(function()
        -- Clean up environment
        vim.env.MACOS_SCREENSHOT_LOG_LEVEL = nil
        vim.env.NODE_ENV = nil
    end)
    
    it("should create log instance", function()
        assert.is_not_nil(log)
        assert.is_function(log.info)
        assert.is_function(log.error)
        assert.is_function(log.debug)
        assert.is_function(log.warn)
        assert.is_function(log.trace)
        assert.is_function(log.fatal)
    end)
    
    it("should have structured logging", function()
        assert.is_function(log.structured)
        
        -- Test structured logging doesn't error
        assert.has_no.errors(function()
            log.structured("info", "test_event", { key = "value", number = 123 })
        end)
    end)
    
    it("should have screenshot-specific logging methods", function()
        assert.is_function(log.screenshot_action)
        assert.is_function(log.screenshot_error)
        
        -- Test screenshot logging doesn't error
        assert.has_no.errors(function()
            log.screenshot_action("test_action", { type = "full", path = "/tmp/test.png" })
            log.screenshot_error("test_error", "Test error message", { context = "test" })
        end)
    end)
    
    it("should handle different log levels", function()
        assert.has_no.errors(function()
            log.trace("Trace message")
            log.debug("Debug message") 
            log.info("Info message")
            log.warn("Warning message")
            log.error("Error message")
            log.fatal("Fatal message")
        end)
    end)
    
    it("should handle log level filtering in debug mode", function()
        -- In test environment, debug messages should work
        assert.has_no.errors(function()
            log.debug("This should work in test mode")
            log.trace("This should work in test mode")
        end)
    end)
    
    it("should handle production environment", function()
        -- Mock production environment
        vim.env.NODE_ENV = "production"
        
        -- Reload logger to pick up new environment
        package.loaded['macos-screenshot.logger'] = nil
        local prod_log = require('macos-screenshot.logger')
        
        -- Debug and trace should be no-ops in production
        assert.has_no.errors(function()
            prod_log.debug("This should be ignored in production")
            prod_log.trace("This should be ignored in production")
            prod_log.info("This should still work in production")
        end)
    end)
end)

describe("vlog integration", function()
    local vlog
    
    before_each(function()
        package.loaded['macos-screenshot.log'] = nil
        vlog = require('macos-screenshot.log')
    end)
    
    it("should load vlog without errors", function()
        assert.is_not_nil(vlog)
        assert.is_function(vlog.new)
    end)
    
    it("should create new log instances", function()
        local logger = vlog.new({
            plugin = "test-plugin",
            level = "debug",
            use_console = false,
            use_file = false
        })
        
        assert.is_not_nil(logger)
        assert.is_function(logger.info)
        assert.is_function(logger.error)
        assert.is_function(logger.debug)
    end)
    
    it("should handle log configuration", function()
        local logger = vlog.new({
            plugin = "test-plugin",
            level = "info",
            use_console = true,
            use_file = false,
            highlights = true,
            float_precision = 0.01,
            modes = {
                { name = "info", hl = "Directory" },
                { name = "error", hl = "ErrorMsg" }
            }
        })
        
        assert.has_no.errors(function()
            logger.info("Test info message")
            logger.error("Test error message")
        end)
    end)
end)