# NVIM Config
Make sure you're using a new enough version of neovim

## Setup From Scratch
1. Clone this repo into `~/.config` and rename it to `nvim`
2. Clone `nvim-treesitter` into `~/.local/share/nvim/site/pack/plugins/start`
3. Download any language servers

## Language Servers
Feel free to use any language servers you like. I've included the ones I'm running below, if you want to use something else just change the configs in `~/.config/nvim/lua/plugins/*`.

**NOTE** Right now I have python managed by uv since its way faster so I had to modify the config to pull pylsp from a uv virtual environment instead of from `/usr/bin/python`, if you decide to manage python another way you can just change this config, the old command (just `pylsp`) should still be there commented out. Put the venv in `/.local/uv-lsp-venv`

language servers:
(Lua LS)[https://github.com/LuaLS/lua-language-server]
    - scroll down to install, click neovim, from latest release
    - extract the file in some directory and point into the bin in PATH

(Python LS)[https://github.com/python-lsp/python-lsp-server]
    - Create a uv venv at `~/.local/uv-lsp-venv`
    - `pip install python-lsp-server` and any functionality you want (e.g. `flake8` [linting], `black` [formatting], `mypy` [type checking], `isort` [import sorting])

(Terraform LS)[https://github.com/hashicorp/terraform-ls]
