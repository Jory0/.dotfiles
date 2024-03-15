export PATH="$HOME/.asdf:$PATH"

# --- Aliases ---
alias vim="nvim"
alias gcm="git commit -m"
alias gcb="git checkout -b"

# --- Helpers ---
gr() {
  git rebase -i HEAD~$1
}
