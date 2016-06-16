# Ubuntu-only stuff. Abort if not Ubuntu.
is_linux || return 1

# If the old files isn't removed, the duplicate APT alias will break sudo!
sudoers_old="/etc/sudoers.d/sudoers-cowboy"; [[ -e "$sudoers_old" ]] && sudo rm "$sudoers_old"

# Installing this sudoers file makes life easier.
sudoers_file="sudoers-dotfiles"
sudoers_src=$DOTFILES/conf/linux/$sudoers_file
sudoers_dest="/etc/sudoers.d/$sudoers_file"
if [[ ! -e "$sudoers_dest" || "$sudoers_dest" -ot "$sudoers_src" ]]; then
  cat <<EOF
The sudoers file can be updated to allow "sudo apt-get" and "sudo yum" to be executed
without asking for a password. You can verify that this worked correctly by
running "sudo -k apt-get"or "sudo -k yum". If it doesn't ask for a password, and the output
looks normal, it worked.

THIS SHOULD ONLY BE ATTEMPTED IF YOU ARE LOGGED IN AS ROOT IN ANOTHER SHELL.

This will be skipped if "Y" isn't pressed within the next $prompt_delay seconds.
EOF
  read -N 1 -t $prompt_delay -p "Update sudoers file? [y/N] " update_sudoers; echo
  if [[ "$update_sudoers" =~ [Yy] ]]; then
    e_header "Updating sudoers"
    visudo -cf "$sudoers_src" &&
    sudo cp "$sudoers_src" "$sudoers_dest" &&
    sudo chmod 0440 "$sudoers_dest" &&
    echo "File $sudoers_dest updated." ||
    echo "Error updating $sudoers_dest file."
  else
    echo "Skipping."
  fi
fi

# Update APT.
e_header "Updating APT"


if is_debian; then
  sudo apt-get -qq update
  sudo apt-get -qq dist-upgrade
else
  sudo yum -qq update
  sudo yum -qq dist-upgrade
fi

# Install APT packages.
packages=(
  ansible
  build-essential
  docker.io
  cowsay
  git-core
  gitk
  chromium-browser
  htop
  id3tool
  libssl-dev
  meld
  mercurial
  nmap
  php
  python
  python-pip
  silversearcher-ag
  sl
  telnet
  tree
  xclip
  vim
  vim-gnome
)

# More APT packages
if is_debian; then
  packages+=(
    php7.0-xml #precisa pro phpunit funcionar
  )
else
  packages+=(
    php70w-xml #precisa pro phpunit funcionar
  )
fi




packages=($(setdiff "${packages[*]}" "$(dpkg --get-selections | grep -v deinstall | awk '{print $1}')"))

if (( ${#packages[@]} > 0 )); then
  e_header "Installing APT packages: ${packages[*]}"
  for package in "${packages[@]}"; do
    if is_debian; then
      sudo apt-get -qq install "$package"
    else
      sudo yum -qq install "$package"
    fi
  done
fi

# Install Git Extras
if [[ ! "$(type -P git-extras)" ]]; then
  e_header "Installing Git Extras"
  (
    cd $DOTFILES/vendor/git-extras &&
    sudo make install
  )
fi

# Install Atom
if [[ ! "$(type -P atom)" ]]; then
  e_header "Installing Atom IDE"
  (
    if is_debian; then
      sudo add-apt-repository ppa:webupd8team/atom -y && sudo apt-get -qq update && sudo apt-get install -qq atom -y
    else
      sudo add-apt-repository ppa:webupd8team/atom -y && sudo yum -qq update && sudo yum install -qq atom -y
    fi
  )
fi

# Install Google-Chrome
if [[ ! "$(type -P google-chrome)" ]]; then
  e_header "Installing Google-Chrome"
  (
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    if is_debian; then
      sudo apt-get -qq update ; sudo apt-get -qq install google-chrome-stable -y
    else
      sudo yum -qq update ; sudo yum -qq install google-chrome-stable -y
    fi
  )
fi

# Install Fabric
if [[ ! "$(type -P fab)" ]]; then
  e_header "Installing Fabric"
  (
    sudo pip install fabric
  )
fi
