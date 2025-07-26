# 📸 macos-screenshot.nvim

一个专业的 macOS 截图管理插件，专为 Neovim 用户打造。基于 [base.nvim](https://github.com/S1M0N38/base.nvim) 模板开发，遵循最佳实践。

## ✨ 特性

- 🖼️ **简洁截图** - 支持全屏和选区截图两种核心模式
- 📋 **智能剪切板** - 自动复制截图路径到系统剪切板
- 📁 **文件管理** - 智能命名、目录组织、重复检测
- 📊 **专业日志** - 集成 vlog.nvim 日志系统，支持结构化日志
- ⚙️ **高度可配置** - 丰富的自定义选项和快捷键
- 🔍 **健康检查** - 完整的系统状态监控和权限检测
- 🧪 **完整测试** - 单元测试和集成测试覆盖
- 📖 **详细文档** - Vim 帮助文档和使用指南

## 📋 系统要求

- **操作系统**: macOS 10.15 (Catalina) 或更高版本
- **Neovim**: 0.7+ (推荐 0.10+)
- **权限**: 屏幕录制权限 (Screen Recording)
- **依赖**: `screencapture` 命令 (macOS 内置)

## 🚀 安装

### lazy.nvim (推荐)

```lua
{
    "your-username/macos-screenshot.nvim",
    dependencies = {
        -- 无外部依赖
    },
    config = function()
        require("macos-screenshot").setup({
            save_path = "~/Documents/Screenshots",
            filename_format = "%Y%m%d_%H%M%S",
            copy_path_format = "home",  -- 使用 ~ 路径
            
            -- Debug 模式配置 (可选)
            debug = {
                auto_enable = false,    -- 设置为 true 自动启用 debug
                log_levels = {"info", "warn", "error"},
                save_system_info = true
            },
            
            keybindings = {
                enabled = true,
                full_screen = "<leader>ss",       -- 全屏截图
                selection = "<leader>sr"          -- 选区截图
            }
        })
    end,
    
    -- 按需加载
    cmd = {
        "Screenshot",
        "ScreenshotSelect"
    },
    
    keys = {
        { "<leader>ss", "<cmd>Screenshot<cr>", desc = "Full screen screenshot" },
        { "<leader>sr", "<cmd>ScreenshotSelect<cr>", desc = "Selection screenshot" },
    }
}
```

### packer.nvim

```lua
use {
    "your-username/macos-screenshot.nvim",
    config = function()
        require("macos-screenshot").setup({
            save_path = "~/Screenshots"
        })
    end
}
```

## ⚙️ 配置

### 默认配置

```lua
require("macos-screenshot").setup({
    -- 基本设置
    save_path = "~/Desktop/Screenshots",  -- 截图保存路径
    filename_format = "%Y%m%d_%H%M%S",    -- 文件名格式 (strftime)
    include_cursor = false,               -- 是否包含鼠标光标
    play_sound = false,                   -- 是否播放截图声音
    copy_path_format = "absolute",        -- 剪切板路径格式: "absolute", "relative", "home"
    monitor_screenshots = true,           -- 是否监控截图目录
    
    -- 日志设置
    log = {
        level = "info",                   -- 日志级别: trace, debug, info, warn, error, fatal
        use_console = true,               -- 控制台输出
        use_file = true,                  -- 文件输出
        highlights = true,                -- 语法高亮
        float_precision = 0.01           -- 浮点数精度
    },
    
    -- Debug 模式设置
    debug = {
        auto_enable = false,              -- 是否自动启用 debug 模式
        log_levels = {"trace", "debug", "info", "warn"},  -- debug 模式下的日志级别
        save_system_info = true           -- 是否保存系统信息
    },
    
    -- 快捷键设置
    keybindings = {
        enabled = true,                   -- 是否启用快捷键
        full_screen = "<leader>ss",       -- 全屏截图
        selection = "<leader>sr"          -- 选区截图
    }
})
```

## 🎮 使用方法

### 命令

```vim
" 核心截图命令
:Screenshot                    " 全屏截图
:ScreenshotSelect             " 选区截图
```

### 快捷键 (默认)

- `<leader>ss` - 全屏截图
- `<leader>sp` - 选区截图（部分）

### Lua API

```lua
local screenshot = require("macos-screenshot")

-- 截图
screenshot.take_screenshot("full")              -- 全屏截图
screenshot.take_screenshot("selection")         -- 选区截图

-- 状态检查
screenshot.is_initialized()                   -- 检查是否已初始化
screenshot.get_config()                       -- 获取当前配置
screenshot.get_state()                        -- 获取插件状态 (调试用)
```

## 🔧 健康检查

运行健康检查以确保插件正常工作：

```vim
:checkhealth macos-screenshot
```

健康检查会验证：
- macOS 环境
- Neovim 版本兼容性
- `screencapture` 命令可用性
- 屏幕录制权限
- 保存目录权限
- 剪切板功能
- 日志系统

## 🐛 Debug 模式

插件支持详细的 debug 模式，用于问题诊断和开发调试。Debug 模式会将详细日志保存到固定位置，方便追踪和分析问题。

### 启用方式

#### 1. 通过命令启用（推荐）
```vim
" 启用 debug 模式
:ScreenshotDebugEnable

" 禁用 debug 模式
:ScreenshotDebugDisable
```

#### 2. 在配置中自动启用
```lua
require("macos-screenshot").setup({
    debug = {
        auto_enable = true,       -- 自动启用 debug 模式
        log_levels = {"trace", "debug", "info", "warn"},  -- 支持的日志级别
        save_system_info = true   -- 启用时保存系统信息
    }
})
```

#### 3. 开发环境配置
```lua
-- 开发者可以使用更详细的配置
require("macos-screenshot").setup({
    log = {
        level = "debug",          -- 设置日志级别为 debug
        use_console = true,
        use_file = true
    },
    debug = {
        auto_enable = true,
        log_levels = {"trace", "debug", "info", "warn", "error"},
        save_system_info = true
    }
})
```

### Debug 功能特性

**固定日志文件**：
- 📁 **文件位置**: `/tmp/macos-screenshot-debug.log`
- 🔄 **更新策略**: 每次启用 debug 模式都会**替换**上一次的日志
- 🔒 **固定文件名**: 便于查找和监控，可以用 `tail -f` 监控
- 📈 **系统信息**: 自动记录系统环境和插件状态

**日志级别支持**：
- `trace` - 最详细的追踪信息
- `debug` - 调试信息和变量状态
- `info` - 一般信息和操作结果
- `warn` - 警告信息
- `error` - 错误信息和异常

**Debug 命令**：
```vim
:ScreenshotDebugEnable     " 启用 debug 模式
:ScreenshotDebugDisable    " 禁用 debug 模式
:ScreenshotDebugLog        " 打开 debug 日志文件
:ScreenshotDebugTail [N]   " 显示最后 N 行日志 (默认 20)
:ScreenshotDebugClear      " 清空 debug 日志
:ScreenshotDebugInfo       " 显示详细的 debug 信息
```

### 使用示例

#### 基本 debug 流程
```vim
" 1. 启用 debug 模式
:ScreenshotDebugEnable

" 2. 测试截图功能
:Screenshot full test_debug

" 3. 查看 debug 日志
:ScreenshotDebugTail 10    " 查看最后 10 行日志
:ScreenshotDebugLog        " 打开完整日志文件

" 4. 禁用 debug 模式
:ScreenshotDebugDisable
```

#### 高级 debug 技巧
```bash
# 终端中实时监控日志
tail -f /tmp/macos-screenshot-debug.log

# 查找特定错误
grep -i error /tmp/macos-screenshot-debug.log

# 查看截图操作
grep "screenshot_" /tmp/macos-screenshot-debug.log
```

#### 故障排除流程
```vim
" 1. 检查健康状态
:checkhealth macos-screenshot

" 2. 启用 debug 并获取详细信息
:ScreenshotDebugEnable
:ScreenshotDebugInfo

" 3. 清空旧日志并重新测试
:ScreenshotDebugClear
:Screenshot

" 4. 查看错误日志
:ScreenshotDebugTail 20
```

### 常见问题与解决

**Q: Debug 模式不生效？**
```vim
" 检查 debug 状态
:ScreenshotDebugInfo

" 确保正确启用
:ScreenshotDebugEnable
```

**Q: 找不到日志文件？**
```bash
# 查找日志文件位置
ls -la /tmp/macos-screenshot-debug.log

# 检查目录权限
ls -ld /tmp
```

**Q: 日志太多太详细？**
```lua
-- 调整日志级别
require("macos-screenshot").setup({
    debug = {
        log_levels = {"info", "warn", "error"}  -- 只显示重要信息
    }
})
```

**Q: 性能影响？**
- Debug 模式会轻微影响性能，仅在需要时启用
- 使用完毕后及时禁用：`:ScreenshotDebugDisable`

### Debug 日志内容

**系统信息**：
- 💻 macOS 版本和架构信息
- 🎯 Neovim 版本和 API 兼容性
- 📂 工作目录和插件路径
- 🔧 环境变量和配置信息

**操作记录**：
- ⏱️ 详细的操作时间线和执行耗时
- 📷 截图命令构建和执行过程
- 📄 文件创建、大小和路径信息
- 📎 剪贴板操作和路径格式化

**错误诊断**：
- 🚫 详细的错误堆栈跟踪
- 🔐 权限检查和系统要求验证
- ⚠️ 警告和异常情况处理

## 🛠️ 开发

### 环境设置

```bash
# 克隆项目
git clone https://github.com/your-username/macos-screenshot.nvim.git
cd macos-screenshot.nvim

# 安装依赖 (macOS)
brew install luarocks
luarocks install busted
luarocks install nlua
```

### 运行测试

```bash
# 运行所有测试
busted

# 运行特定测试
busted spec/macos-screenshot_spec.lua

# 详细输出
busted --verbose

# 生成覆盖率报告
busted --coverage
```

### 本地测试

```bash
# 使用测试配置启动 Neovim
nvim -u test-config.lua

# 运行健康检查
:checkhealth macos-screenshot

# 测试截图功能
:Screenshot
```

## 📚 文档

- 📖 [Vim 帮助文档](doc/macos-screenshot.txt) - `:help macos-screenshot`
- 🏗️ [架构设计](docs/architecture.md) - 插件架构和设计原理
- 🇨🇳 [中文使用指南](docs/usage-zh.md) - 详细的中文文档

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详细的贡献指南。

## 📄 许可证

本项目采用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [base.nvim](https://github.com/S1M0N38/base.nvim) - 提供了优秀的插件开发模板
- [vlog.nvim](https://github.com/tjdevries/vlog.nvim) - 强大的日志系统
- Neovim 社区 - 持续的支持和反馈

## 📮 支持

如有问题或建议，请：

- 🐛 [提交 Issue](https://github.com/your-username/macos-screenshot.nvim/issues)
- 💬 [参与讨论](https://github.com/your-username/macos-screenshot.nvim/discussions)
- 📖 [查看 Wiki](https://github.com/your-username/macos-screenshot.nvim/wiki)

---

**⭐ 如果这个项目对你有帮助，请给它一个星标！**