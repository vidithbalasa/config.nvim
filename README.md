# NVIM Config
I'm assuming no one's gonna read this. It's mostly just for me for future reference.

### Setup
Just put this whole git repo in `~/.config`, download the plugins below (or change config to remove them) and you should be good to go

### Plugins
I only use one plugin with this config, rest of the features are built in house. You need to download `nvim-treesitter`. I don't have a plugin manager since I don't really use any other plugins but you can just put it in `~/.local/share/nvim/site/pack/plugins/start` and neovim should pick it up automatically.

### Language Servers
Feel free to use any language servers you like. I've included the ones I'm running below, if you want to use something else just change the configs in `~/.config/nvim/lua/plugins/*`.

**NOTE** Right now I have python managed by uv since its way faster so I had to modify the config to pull pylsp from a uv virtual environment instead of from `/usr/bin/python`, if you decide to manage python another way you can just change this config, the old command (just `pylsp`) should still be there commented out

My language servers:
- (Lua LS)[https://github.com/LuaLS/lua-language-server]
- (Python LS)[https://github.com/python-lsp/python-lsp-server]
- (Terraform LS)[https://github.com/hashicorp/terraform-ls]
