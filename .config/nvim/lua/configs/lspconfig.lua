require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"
local nvlsp = require "nvchad.configs.lspconfig"

local servers = {
  "bashls",
  "clangd",
  "cmake",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "eslint",
  "gitlab_ci_ls",
  "html",
  "hyprls",
  "marksman",
  "nginx_language_server",
  "pyright",
  "rust_analyzer",
  "tailwindcss",
  "vimls",
  "yamlls",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end
