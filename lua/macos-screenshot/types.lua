---@meta

---@class MacosScreenshotConfig
---@field save_path string 截图保存路径
---@field filename_format string 文件名格式 (strftime format)
---@field include_cursor boolean 是否包含鼠标光标
---@field play_sound boolean 是否播放截图声音
---@field copy_path_format "absolute"|"relative"|"home" 剪切板路径格式
---@field monitor_screenshots boolean 是否监控截图目录
---@field log MacosScreenshotLogConfig 日志配置
---@field keybindings MacosScreenshotKeybindings 快捷键配置

---@class MacosScreenshotLogConfig
---@field level "trace"|"debug"|"info"|"warn"|"error"|"fatal" 日志级别
---@field use_console boolean 是否输出到控制台
---@field use_file boolean 是否输出到文件
---@field highlights boolean 是否启用语法高亮
---@field float_precision number 浮点数精度

---@class MacosScreenshotKeybindings
---@field enabled boolean 是否启用快捷键
---@field screenshot string 交互式截图快捷键
---@field full_screen string 全屏截图快捷键
---@field window string 窗口截图快捷键
---@field selection string 区域截图快捷键

---@class MacosScreenshotCaptureOptions
---@field type "interactive"|"full"|"window"|"selection"|"window_id" 截图类型
---@field output string 输出文件路径
---@field window_id? number 窗口ID (仅当type为window_id时使用)
---@field on_success? fun(path: string) 成功回调
---@field on_error? fun(error: string) 错误回调

---@class MacosScreenshotState
---@field initialized boolean 是否已初始化
---@field active_jobs table<number, boolean> 活跃的任务
---@field last_screenshot string|nil 最后一次截图路径
---@field monitor_job number|nil 监控任务ID