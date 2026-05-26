return {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    ".venv", "WORKSPACE", "pyproject.toml", "setup.py",
    "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json",
  },
  settings = {
    python = {
      pythonPath = vim.fn.exepath("python3"),
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
}
