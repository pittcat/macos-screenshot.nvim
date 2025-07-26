local plugin_name = "macos-screenshot.nvim"

local spec = {
  name = plugin_name,
  version = "scm-1",
  source = {
    url = "git://github.com/pittcat/" .. plugin_name,
  },
  description = {
    summary = "Professional macOS screenshot management plugin for Neovim",
    detailed = [[
      macOS Screenshot Plugin provides seamless screenshot capture integration
      within Neovim, designed specifically for macOS users. Features include
      multiple capture modes, automatic clipboard integration, file monitoring,
      comprehensive logging, and extensive customization options.
      
      Built using base.nvim template with professional development practices,
      comprehensive testing, and complete documentation.
    ]],
    homepage = "https://github.com/pittcat/" .. plugin_name,
    license = "MIT",
  },
  dependencies = {
    "lua >= 5.1, < 5.5",
  },
  build = {
    type = "builtin",
  },
  supported_platforms = {
    "macosx"
  }
}

if not spec.source.url:find("https") and os.getenv "GITHUB_TOKEN" then
  spec.source.url = spec.source.url:gsub("git://github.com", "https://github.com")
end

return spec