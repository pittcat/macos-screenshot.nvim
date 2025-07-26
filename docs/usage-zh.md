# 📸 macos-screenshot.nvim 使用指南

这是一个详细的中文使用指南，帮助你充分利用 macos-screenshot.nvim 插件的所有功能。

## 📋 目录

- [快速开始](#快速开始)
- [基本使用](#基本使用)
- [高级配置](#高级配置)
- [命令参考](#命令参考)
- [API 参考](#api-参考)
- [故障排除](#故障排除)
- [最佳实践](#最佳实践)

## 🚀 快速开始

### 最简安装

使用 lazy.nvim 的最简配置：

```lua
{
    "your-username/macos-screenshot.nvim",
    config = true,  -- 使用默认配置
    keys = {
        { "<leader>ss", "<cmd>Screenshot<cr>", desc = "截图" }
    }
}
```

### 验证安装

安装后运行健康检查：

```vim
:checkhealth macos-screenshot
```

所有检查通过后，尝试第一次截图：

```vim
:Screenshot
```

## 🎯 基本使用

### 截图模式

插件支持四种截图模式：

#### 1. 交互式截图 (默认)
```vim
:Screenshot
" 或
:ScreenshotInteractive
```
- 按空格键：全屏截图
- 点击窗口：窗口截图  
- 拖拽选择：区域截图
- 按 ESC：取消

#### 2. 全屏截图
```vim
:ScreenshotFull
" 或
:Screenshot full
```
- 直接截取整个屏幕

#### 3. 窗口截图
```vim
:ScreenshotWindow
" 或  
:Screenshot window
```
- 点击要截取的窗口

#### 4. 区域截图
```vim
:ScreenshotSelection
" 或
:Screenshot selection
```
- 拖拽选择要截取的区域

### 自定义文件名

所有截图命令都可以指定自定义基础文件名：

```vim
:Screenshot full my_desktop
:ScreenshotWindow app_interface
:Screenshot selection ui_mockup
```

生成的文件名格式：`{basename}_{timestamp}.png`

例如：`my_desktop_20240127_143022.png`

### 快捷键使用

默认快捷键（可在配置中修改）：

- `<leader>ss` - 交互式截图
- `<leader>sf` - 全屏截图
- `<leader>sw` - 窗口截图
- `<leader>sr` - 区域截图

## ⚙️ 高级配置

### 完整配置示例

```lua
{
    "your-username/macos-screenshot.nvim",
    config = function()
        require("macos-screenshot").setup({
            -- 基本设置
            save_path = "~/Documents/Screenshots",  -- 保存路径
            filename_format = "%Y%m%d_%H%M%S",      -- 时间格式
            include_cursor = false,                  -- 是否包含光标
            play_sound = false,                     -- 是否播放声音
            copy_path_format = "home",              -- 剪切板路径格式
            
            -- 日志配置
            log = {
                level = "info",        -- trace, debug, info, warn, error, fatal
                use_console = true,    -- 控制台输出
                use_file = false,      -- 文件输出
                highlights = true      -- 语法高亮
            },
            
            -- 快捷键配置
            keybindings = {
                enabled = true,
                screenshot = "<leader>ss",
                full_screen = "<leader>sf", 
                window = "<leader>sw",
                selection = "<leader>sr"
            }
        })
    end,
    
    -- 按需加载
    cmd = {
        "Screenshot", "ScreenshotFull", "ScreenshotWindow", 
        "ScreenshotSelection", "ScreenshotInteractive"
    },
    
    keys = {
        { "<leader>ss", desc = "交互式截图" },
        { "<leader>sf", desc = "全屏截图" },
        { "<leader>sw", desc = "窗口截图" },
        { "<leader>sr", desc = "区域截图" },
    }
}
```

### 配置选项详解

#### 路径和文件名

```lua
{
    save_path = "~/Pictures/Screenshots",       -- 保存目录
    filename_format = "%Y-%m-%d_%H-%M-%S",     -- strftime 格式
    copy_path_format = "absolute"              -- 剪切板路径格式
}
```

**copy_path_format 选项：**
- `"absolute"` - 完整路径：`/Users/username/Screenshots/screenshot.png`
- `"relative"` - 相对路径：`./Screenshots/screenshot.png`
- `"home"` - 家目录路径：`~/Screenshots/screenshot.png`

#### 截图行为

```lua
{
    include_cursor = true,    -- 截图中包含鼠标光标
    play_sound = true,        -- 播放拍照声音
    monitor_screenshots = true -- 监控截图目录变化
}
```

#### 日志系统

```lua
{
    log = {
        level = "debug",           -- 日志级别
        use_console = true,        -- 在 Neovim 中显示日志
        use_file = true,          -- 保存到日志文件
        highlights = true,         -- 使用颜色高亮
        float_precision = 0.01    -- 浮点数精度
    }
}
```

### 自定义快捷键

如果你想使用不同的快捷键：

```lua
{
    keybindings = {
        enabled = true,
        screenshot = "<C-s>",          -- Ctrl+S
        full_screen = "<leader>ps",    -- 自定义前缀
        window = "<F12>",              -- 功能键
        selection = "<leader><leader>s" -- 双 leader
    }
}
```

或者完全禁用自动快捷键，手动设置：

```lua
-- 在配置中禁用
{
    keybindings = { enabled = false }
}

-- 手动设置快捷键
vim.keymap.set('n', '<C-s>', function()
    require('macos-screenshot').take_screenshot('interactive')
end, { desc = '截图' })

vim.keymap.set('n', '<C-S-s>', function()
    require('macos-screenshot').take_screenshot('full')
end, { desc = '全屏截图' })
```

## 📝 命令参考

### 主要命令

| 命令 | 参数 | 描述 | 示例 |
|------|------|------|------|
| `:Screenshot` | `[type] [basename]` | 通用截图命令 | `:Screenshot full desktop` |
| `:ScreenshotFull` | `[basename]` | 全屏截图 | `:ScreenshotFull my_screen` |
| `:ScreenshotWindow` | `[basename]` | 窗口截图 | `:ScreenshotWindow app_window` |
| `:ScreenshotSelection` | `[basename]` | 区域截图 | `:ScreenshotSelection ui_part` |
| `:ScreenshotInteractive` | `[basename]` | 交互式截图 | `:ScreenshotInteractive` |

### 工具命令

| 命令 | 描述 |
|------|------|
| `:ScreenshotOpenLast` | 在默认应用中打开最后一张截图 |
| `:ScreenshotRevealLast` | 在 Finder 中显示最后一张截图 |
| `:ScreenshotInfo` | 显示最后一张截图的详细信息 |
| `:MacosScreenshotSetup` | 简单的设置命令 |

### 管理命令

```vim
" 健康检查
:checkhealth macos-screenshot

" 简单设置（键值对格式）
:MacosScreenshotSetup save_path=~/Pictures include_cursor=true

" 查看插件状态
:lua print(vim.inspect(require('macos-screenshot').get_state()))

" 查看当前配置
:lua print(vim.inspect(require('macos-screenshot').get_config()))
```

## 🔧 API 参考

### 基本 API

```lua
local screenshot = require('macos-screenshot')

-- 插件初始化
screenshot.setup({
    save_path = "~/Screenshots",
    log = { level = "info" }
})

-- 截图操作
screenshot.take_screenshot('full')                    -- 全屏
screenshot.take_screenshot('window', 'app_window')    -- 窗口 + 自定义名称
screenshot.take_screenshot('selection')               -- 区域
screenshot.take_screenshot('interactive')             -- 交互式

-- 获取信息
local last_path = screenshot.get_last_screenshot()    -- 最后截图路径
local is_ready = screenshot.is_initialized()          -- 是否已初始化
local config = screenshot.get_config()                -- 当前配置
local state = screenshot.get_state()                  -- 插件状态

-- 工具操作
screenshot.open_last_screenshot()                     -- 打开最后截图
screenshot.reveal_last_screenshot()                   -- 在 Finder 中显示
screenshot.show_last_screenshot_info()                -- 显示截图信息
```

### 日志 API

```lua
-- 访问日志系统
local log = screenshot.log

-- 基本日志
log.info("信息消息")
log.warn("警告消息")
log.error("错误消息")
log.debug("调试消息")

-- 结构化日志
log.structured("info", "custom_event", {
    user = "test_user",
    action = "screenshot",
    timestamp = os.time()
})

-- 截图专用日志
log.screenshot_action("started", { type = "full" })
log.screenshot_error("permission_denied", "需要屏幕录制权限")
```

### 异步回调模式

对于需要精确控制的场景：

```lua
local screencapture = require('macos-screenshot.screencapture')

screencapture.capture({
    type = 'full',
    output = '/tmp/my_screenshot.png',
    on_success = function(path)
        print("截图成功：", path)
        -- 自定义后处理
        vim.cmd("edit " .. path)  -- 在 Neovim 中打开图片
    end,
    on_error = function(error)
        print("截图失败：", error)
        vim.notify(error, vim.log.levels.ERROR)
    end
})
```

## 🩺 故障排除

### 常见问题和解决方案

#### 1. 插件无法加载

**症状：** 插件命令不可用或报错

**解决方案：**
```vim
" 检查 macOS 环境
:lua print(vim.loop.os_uname().sysname)  -- 应该显示 "Darwin"

" 检查 Neovim 版本
:lua print(vim.version())  -- 需要 0.7+

" 运行健康检查
:checkhealth macos-screenshot
```

#### 2. 截图权限问题

**症状：** 截图失败，提示权限错误

**解决方案：**
1. 打开系统偏好设置 → 安全性与隐私 → 隐私 → 屏幕录制
2. 添加你的终端应用（Terminal.app、iTerm2 等）
3. 重启终端和 Neovim

#### 3. 剪切板不工作

**症状：** 截图成功但路径未复制到剪切板

**解决方案：**
```vim
" 检查 pbcopy 命令
:lua print(vim.fn.executable('pbcopy'))  -- 应该返回 1

" 测试内置剪切板
:lua vim.fn.setreg('+', 'test'); print(vim.fn.getreg('+'))

" 检查剪切板配置
:lua print(vim.inspect(require('macos-screenshot').get_config().copy_path_format))
```

#### 4. 文件保存问题

**症状：** 截图命令执行但文件未保存

**解决方案：**
```vim
" 检查保存目录
:lua local cfg = require('macos-screenshot').get_config(); print(cfg.save_path)

" 检查目录权限
:lua local dir = require('macos-screenshot').get_config().save_path; print(vim.fn.isdirectory(dir), vim.fn.filewritable(dir))

" 手动创建目录
:lua vim.fn.mkdir(require('macos-screenshot').get_config().save_path, 'p')
```

#### 5. 快捷键冲突

**症状：** 设置的快捷键不生效

**解决方案：**
```vim
" 检查快捷键绑定
:map <leader>ss

" 禁用自动快捷键，手动设置
lua require('macos-screenshot').setup({ keybindings = { enabled = false } })

" 手动绑定新快捷键
nnoremap <C-s> :Screenshot<CR>
```

### 调试模式

启用详细日志以诊断问题：

```lua
require('macos-screenshot').setup({
    log = {
        level = "trace",      -- 最详细的日志级别
        use_console = true,   -- 在 Neovim 中显示
        use_file = true      -- 保存到文件
    }
})
```

查看日志文件：

```vim
:lua print(vim.fn.stdpath('data') .. '/macos-screenshot.nvim.log')
```

### 获取帮助

如果问题仍然存在：

1. 运行 `:checkhealth macos-screenshot` 并截图结果
2. 启用调试日志并重现问题
3. 在 GitHub 仓库创建 Issue，包含：
   - 系统信息（macOS 版本、Neovim 版本）
   - 插件配置
   - 健康检查结果
   - 错误消息和日志

## 💡 最佳实践

### 1. 文件组织

建议的截图目录结构：

```
~/Screenshots/
├── daily/          # 日常截图
├── work/           # 工作相关
├── projects/       # 项目截图
│   ├── project-a/
│   └── project-b/
└── temp/           # 临时截图
```

配置示例：

```lua
-- 为不同用途创建不同的设置
local function setup_work_screenshots()
    require('macos-screenshot').setup({
        save_path = "~/Screenshots/work",
        filename_format = "work_%Y%m%d_%H%M%S",
        copy_path_format = "relative"
    })
end

local function setup_project_screenshots()
    require('macos-screenshot').setup({
        save_path = vim.fn.getcwd() .. "/docs/screenshots",
        filename_format = "doc_%Y%m%d_%H%M%S", 
        copy_path_format = "relative"
    })
end
```

### 2. 快捷键策略

推荐的快捷键设置：

```lua
{
    keybindings = {
        enabled = true,
        screenshot = "<leader>sc",      -- sc = screenshot
        full_screen = "<leader>sf",     -- sf = screenshot full
        window = "<leader>sw",          -- sw = screenshot window  
        selection = "<leader>ss"        -- ss = screenshot selection
    }
}
```

### 3. 工作流集成

#### 与文档写作集成

```lua
-- 为 Markdown 文档创建截图
local function doc_screenshot()
    local current_file = vim.fn.expand('%:p:h')
    local doc_dir = current_file .. '/assets'
    
    -- 确保目录存在
    vim.fn.mkdir(doc_dir, 'p')
    
    -- 临时更改配置
    require('macos-screenshot').setup({
        save_path = doc_dir,
        copy_path_format = "relative"
    })
    
    -- 截图
    require('macos-screenshot').take_screenshot('selection', 'doc_image')
end

vim.keymap.set('n', '<leader>di', doc_screenshot, { desc = '文档截图' })
```

#### 与项目管理集成

```lua
-- 为当前项目创建截图
local function project_screenshot()
    local project_root = vim.fn.system('git rev-parse --show-toplevel'):gsub('\n', '')
    if vim.v.shell_error == 0 then
        require('macos-screenshot').setup({
            save_path = project_root .. '/screenshots',
            filename_format = "project_%Y%m%d_%H%M%S"
        })
    end
    
    require('macos-screenshot').take_screenshot('interactive')
end
```

### 4. 自动化工作流

#### 自动打开编辑器

```lua
-- 截图后自动在图片编辑器中打开
local function screenshot_and_edit()
    require('macos-screenshot').take_screenshot('selection', nil, function(success, path)
        if success then
            -- 在 Preview 中打开以便编辑
            vim.fn.system('open -a Preview ' .. vim.fn.shellescape(path))
        end
    end)
end
```

#### 自动插入 Markdown 链接

```lua
-- 截图后自动插入 Markdown 链接
local function markdown_screenshot()
    require('macos-screenshot').take_screenshot('selection', 'md_image', function(success, path)
        if success and vim.bo.filetype == 'markdown' then
            local filename = vim.fn.fnamemodify(path, ':t')
            local relative_path = './assets/' .. filename
            local markdown_link = string.format('![Screenshot](%s)', relative_path)
            
            -- 在当前位置插入链接
            local current_line = vim.api.nvim_get_current_line()
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            local new_line = current_line:sub(1, cursor_pos[2]) .. markdown_link .. current_line:sub(cursor_pos[2] + 1)
            vim.api.nvim_set_current_line(new_line)
        end
    end)
end
```

### 5. 性能优化

#### 延迟加载

```lua
{
    "your-username/macos-screenshot.nvim",
    lazy = true,
    cmd = { "Screenshot", "ScreenshotFull" },  -- 仅在需要时加载
    keys = {
        { "<leader>ss", "<cmd>Screenshot<cr>", desc = "截图" }
    },
    config = function()
        require("macos-screenshot").setup({
            log = { use_file = false }  -- 禁用文件日志以提高性能
        })
    end
}
```

#### 批量截图

```lua
-- 批量截图功能
local function batch_screenshots()
    local screenshots = {
        { type = 'full', name = 'desktop' },
        { type = 'window', name = 'active_window' },
        { type = 'selection', name = 'ui_element' }
    }
    
    for i, shot in ipairs(screenshots) do
        vim.defer_fn(function()
            require('macos-screenshot').take_screenshot(shot.type, shot.name)
        end, (i - 1) * 2000)  -- 每2秒一张
    end
end
```

这个详细的使用指南应该能帮助用户充分利用 macos-screenshot.nvim 的所有功能！