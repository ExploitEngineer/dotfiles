# Environment that points CLI tools at the files the wallbash hooks generate.
# POSIX sh, sourced by both ~/.bashrc and ~/.config/zsh/user.zsh.
# Every line is guarded, so it is harmless before the hooks have run once.

# lazygit lists wallbash.yml first and config.yml last, so the user's own
# settings win on any overlap. It errors on a missing file, hence the guards.
if [ -f "$HOME/.config/lazygit/wallbash.yml" ]; then
    LG_CONFIG_FILE="$HOME/.config/lazygit/wallbash.yml"
    [ -f "$HOME/.config/lazygit/config.yml" ] && LG_CONFIG_FILE="$LG_CONFIG_FILE,$HOME/.config/lazygit/config.yml"
    export LG_CONFIG_FILE
fi

# fzf reads its colours from a file the fzf hook writes. A user's own
# FZF_DEFAULT_OPTS_FILE is left alone; FZF_DEFAULT_OPTS still applies on top.
if [ -z "${FZF_DEFAULT_OPTS_FILE:-}" ] && [ -f "$HOME/.config/fzf/wallbash.opts" ]; then
    export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/wallbash.opts"
fi
