#!/bin/bash

ASDF_INSTALL_DIR="$HOME/.asdf"

asdf_command() {
 zsh -c ". $ASDF_INSTALL_DIR/asdf.sh && $1"
}

symlink_config_dir() {
  config_dir=$PWD/config
  for dir in "$config_dir"/*
  do
    for config in "$dir"/.[^.]*
    do
      file_name=$(basename $config)
      if [ -f "$HOME/$file_name" ]; then
        echo "'$file_name' already exists. Deleting"
        sudo rm "$HOME/$file_name"
      fi
  
      echo "linking $config to home directory"
      ln -s $config "$HOME/$file_name"
    done
  done
}

update_shell() {
  local shell_path;
  shell_path="$(command -v zsh)"

  echo "Changing your shell to zsh ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    echo "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
}

# --- Dotfiles & bin folder ---
symlink_config_dir


# TODO: iterate over list of packages to install; move to function
sudo apt-get update -qq

sudo apt-get -qq --yes install curl zsh git neovim fzf ripgrep

if [ ! -d $ASDF_INSTALL_DIR ]
  then
    git clone "https://github.com/asdf-vm/asdf.git" $ASDF_INSTALL_DIR --branch v0.14.0
  else
    echo "$ASDF_INSTALL_DIR already exists"
fi

asdf_command 'asdf update'
asdf_command 'asdf plugin add nodejs'
asdf_command 'asdf plugin add go https://github.com/asdf-community/asdf-golang'
asdf_command 'asdf plugin add lua'
asdf_command 'asdf install nodejs latest && asdf global nodejs latest'
asdf_command 'asdf install go latest && asdf global go latest'
asdf_command 'asdf install lua latest && asdf global lua latest'

# --- Non-dev specific stuff ---
# 1Pass
if [ ! -f /usr/share/keyrings/1password-archive-keyring.gpg ]
  then
    /usr/bin/curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    sudo apt-get -qq --yes install 1password
  else
    echo "1Password already installed"
fi

case "$SHELL" in
  */zsh)
    if [ "$(command -v zsh)" != "/usr/bin/zsh" ] ; then
      update_shell
    fi
    ;;
  *)
    update_shell
    ;;
esac

