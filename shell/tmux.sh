if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
  tmux new -As main
fi
