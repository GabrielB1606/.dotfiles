#!/bin/bash

# Bootstrap the neovim python venv used by molten-nvim / jupytext.nvim
# Packages: pynvim (nvim rpc), jupyter_client + nbformat (molten), jupytext
# (ipynb <-> markdown), cairosvg + pnglatex + pillow + pyperclip (molten extras)

set -euo pipefail

VENV="$HOME/.venvs/neovim"

if [ ! -x "$VENV/bin/python" ]; then
  python3 -m venv "$VENV"
fi

"$VENV/bin/pip" install --quiet --upgrade pip

"$VENV/bin/pip" install --quiet \
  pynvim \
  jupyter_client \
  nbformat \
  jupytext \
  cairosvg \
  pnglatex \
  pillow \
  pyperclip \
  numpy \
  scipy \
  matplotlib \
  matplotlib-inline

# Register a python3 kernel for the venv so molten can find it everywhere
"$VENV/bin/pip" install --quiet ipykernel
"$VENV/bin/python" -m ipykernel install --user --name python3 --display-name "Neovim Python 3" || true
# Drop the sys-prefix kernelspec: it uses a bare `python` argv that shadows
# the user kernelspec and breaks kernel startup from nvim
rm -rf "$VENV/share/jupyter/kernels/python3"
# jupyter_client needs the runtime dir to exist or kernel startup fails
mkdir -p "$HOME/.local/share/jupyter/runtime"

echo "neovim venv ready at $VENV"
