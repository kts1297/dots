if status is-interactive
    # Commands to run in interactive sessions can go here
end
alias v="nvim"
alias l="eza --all --hyperlink"
alias ll="l --long"
alias lls="ll --sort=modified"
alias llsr="lls --reverse"
alias lt="ll --tree"
alias lg="lazygit"
alias g="git"
alias k='kubectl'
alias d='docker'
alias ts='tmux new -s'
alias tl='tmux ls'
alias ta='tmux attach -t'
alias tkss='tmux kill-session -t'
alias ldd='otool -L'

alias es='/opt/homebrew/opt/emacs-plus@29/bin/emacs --fg-daemon'
alias ec='emacsclient'
alias e='emacs -nw'

export PKG_CONFIG_PATH="/opt/homebrew/opt/poppler/lib/pkgconfig:$PKG_CONFIG_PATH"
set -Ux EDITOR nvim

fzf --fish | source

zoxide init fish | source

alias fzf='fzf -m --tmux'
