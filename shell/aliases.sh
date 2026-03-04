# bash
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ls='ls --color=auto'

# programming
alias py='python3'
alias gccobj='gcc -c'

#screen
alias monitor="~/.config/screenlayout/monitors.sh"
alias m_home="~/.config/screenlayout/home_monitor_layout.sh"
alias m_laptop="~/.config/screenlayout/laptop_only_layout.sh"

# TUIs
alias v='nvim'
alias bt='bluetui'
alias wifi='nmtui'

# systems
alias sleepnow='systemctl suspend'
alias jarvis='ollama run qwen2.5-coder:7b'

# git
alias gitadd='git add . & git status'
alias gitdate='git add . && git commit -m "$(date +%Y-%m-%d_%H-%M)" && git push'
alias gitlog='git log --graph --oneline --decorate'

# home server
alias homeserver='ssh -t homeserver@192.168.1.234'
