-- run-busted-nlua.lua
-- 在 nlua 环境中运行 busted 的启动脚本

-- 设置 arg 表（busted 需要这个）
local original_arg = arg or {}
arg = {}
-- arg[0] 应该是脚本名称
arg[0] = original_arg[0] or "run-busted-nlua.lua"
-- 复制其他参数
for i = 1, #original_arg do
  arg[i] = original_arg[i]
end
-- 如果没有参数，从 ... 获取
if #arg == 0 then
  local args = {...}
  for i = 1, #args do
    arg[i] = args[i]
  end
end

-- 确保路径正确
local luarocks_path = "/Users/pittcat/.luarocks/share/lua/5.1/?.lua;/Users/pittcat/.luarocks/share/lua/5.1/?/init.lua"
local luarocks_cpath = "/Users/pittcat/.luarocks/lib/lua/5.1/?.so"

package.path = luarocks_path .. ";" .. package.path
package.cpath = luarocks_cpath .. ";" .. package.cpath

-- 运行 busted
require 'busted.runner'({ standalone = false })