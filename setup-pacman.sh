#!/bin/bash

# install packages

# install tpm (tmux package manager)

# stow configs
stow nvim

# neovim python venv (jupytext, molten-nvim, pynvim...)
./setup-nvim-venv.sh

# opencode config + vibi.top provider key (needs .env, see .env.example)
./setup-opencode.sh

# hermes config + vibi.top provider key (needs .env, see .env.example)
./setup-hermes.sh
