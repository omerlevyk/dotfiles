# history
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

shopt -s histappend
shopt -s checkwinsize

# ls colors via dircolors (Linux)
if command -v dircolors >/dev/null 2>&1; then
  if [ -r "$HOME/.dircolors" ]; then
    eval "$(dircolors -b "$HOME/.dircolors")"
  else
    eval "$(dircolors -b)"
  fi
fi

# terminal colors
export TERM=xterm-256color
export COLORTERM=truecolor

# PATH
export PATH="$HOME/.local/bin:$PATH"
