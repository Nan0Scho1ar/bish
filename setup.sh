#!/bin/sh
# Script to init arch/ubuntu/windows_10 systems to nanOS

# Add colour vars
if [ -t 1 ] && command -v tput > /dev/null; then
    # see if it supports colors
    ncolors=$(tput colors)
    if [ -n "$ncolors" ] && [ $ncolors -ge 8 ]; then
        bold="$(tput bold       || echo)"
        blink="$(tput blink     || echo)"
        reset="$(tput sgr0      || echo)"
        black="$(tput setaf 0   || echo)"
        red="$(tput setaf 1     || echo)"
        green="$(tput setaf 2   || echo)"
        yellow="$(tput setaf 3  || echo)"
        blue="$(tput setaf 4    || echo)"
        magenta="$(tput setaf 5 || echo)"
        cyan="$(tput setaf 6    || echo)"
        white="$(tput setaf 7   || echo)"
    fi
fi


trypacmaninstall() {
    pacman -Qi "$1" 1>/dev/null 2>/dev/null && echo "$1 is already installed" && return
    #Idk if this check works properly
    pacman -Qg "$1" 1>/dev/null 2>/dev/null && echo "$1 is already installed" && return
    echo "Installing $1" && sudo pacman -S "$1"
}

tryaurinstall() {
    pacman -Qi "$1" 1>/dev/null 2>/dev/null && echo "$1 is already installed" && return
    #Idk if this check works properly
    pacman -Qg "$1" 1>/dev/null 2>/dev/null && echo "$1 is already installed" && return
    echo "Installing $1" && yay -S "$1";
}

tryaptinstall() { echo "Installing $1" && sudo apt install "$1"; }

wait_any_key() { read -n 1 -s -r -p "Press any key to continue"; }

#Promts the user to answer a yes/no question.
#Returns after a single char is entered without hitting return.
ask() {
    read -p "${1} ${yellow}y/n${reset} " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && return 0 || return 1
}

asklink() {
    if ask "Link $1"; then
	#Create dir if not exist
	mkdir -p "$(dirname "${3}")"
        if [ -f "$3" ]; then
            rm "$3"
        fi
        ln -sf "$2" "$3"
    fi
}

asklinkdir() {
    if ask "Link $1"; then
	#Create dir if not exist
        #if [ -d "$3" ]; then
             rmdir "$3" 2>/dev/null || rm -r "$3"
        #fi
        ln -sf "$2" "$3"
    fi
}

asklinksudo() {
    if ask "Link $1"; then
	#Create dir if not exist
	sudo mkdir -p "$(dirname "${3}")"
        if [ -f "$3" ]; then
            sudo rm "$3"
        fi
        sudo ln -sf "$2" "$3"
    fi
}

askclone() {
    if [ -d $1 ]; then
        echo "Directory $1 already exists, skipping..."
    elif ask "Clone ${1}"; then
        echo "Cloning $1"
        git clone $2
    fi
}

setup_ssh() {
    if [ -d .ssh ]; then
        echo ".ssh directory already exits, continuing...";
    else
        echo "Creating .ssh directory";
        mkdir .ssh
    fi
    if [ -f .ssh/id_rsa.pub ]; then
        echo "ssh key already exists";
        echo "Using existing key";
    else
        echo "Generating ssh key..."
        ssh-keygen
    fi
    ask "cat public key" && cat .ssh/id_rsa.pub
    echo "Add ssh key to bitbucket before continuing."
    sh firefox "https://id.atlassian.com/login?application=bitbucket"
    wait_any_key
}

#Detect OS
case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    export NANOS_NAME=linux
    ;;
  darwin*)
    export NANOS_NAME=osx
    ;;
  msys*)
    export NANOS_NAME=windows
    ;;
  MINGW64_NT-10.0*)
    export NANOS_NAME=windows
    ;;
  *)
    export NANOS_NAME=notset
    ;;
esac
# TODO Warn if NANOS_NAME = notset

#Detect distro
if [ $NANOS_NAME = "linux" ]; then
    distros=("Arch" "Ubuntu")
    select opt in "${distros}"; do
        NANOS_DISTRO="$opt"
        break
    done
elif [ $NANOS_NAME = "linux" ]; then
    NANOS_DISTRO="Windows"
else
    NANOS_DISTRO="N/A"
fi

#Set repos dir
NANOS_REPOS_DIR="~/repos"
if [ $NANOS_NAME = "linux" ]; then
    NANOS_REPOS_DIR="~/repos"
elif [ $NANOS_NAME = "windows" ]; then
    NANOS_REPOS_DIR="~/source/repos"
fi


# BEGIN

cd ~

# Setup ssh
ask "Setup ssh" && setup_ssh

# Clone repos
askclone "dotfiles" "git@bitbucket.org:Nan0Scho1ar/dotfiles.git"
askclone "scripts" "git@bitbucket.org:Nan0Scho1ar/scripts.git"
askclone "vimwiki" "git@bitbucket.org:Nan0Scho1ar/vimwiki.git"

echo $NANOS_REPOS_DIR
mkdir -p "$NANOS_REPOS_DIR"
cd $NANOS_REPOS_DIR

# Build and install repos
##TODO Build and install
cd ~



# Update system
if [ $NANOS_DISTRO = "Arch" ]; then
    sudo pacman -Syu
    yay -Syu
elif [ $NANOS_DISTRO = "Ubuntu" ]; then
    sudo apt update
    sudo apt upgrade
##TODO Windows
fi


# Install packages
## Arch
if [ $NANOS_DISTRO = "Arch" ]; then
    ### Pacman
    trypacmaninstall fd
    trypacmaninstall ripgrep
    trypacmaninstall fzf
    trypacmaninstall neovim
    trypacmaninstall flameshot
    trypacmaninstall synergy
    trypacmaninstall steam
    trypacmaninstall keychain
    trypacmaninstall code
    trypacmaninstall youtube-dl
    trypacmaninstall mpv
    trypacmaninstall youtube-viewer
    trypacmaninstall zathura
    trypacmaninstall bat

    ### AUR
    tryaurinstall minecraft-launcher
    tryaurinstall pandoc
    tryaurinstall texlive-most
    tryaurinstall postman
    ###TODO Install Rider

## Ubuntu
elif [ $NANOS_DISTRO = "Ubuntu" ]; then
    tryaptinstall fd
    tryaptinstall ripgrep
    tryaptinstall fzf
    tryaptinstall flameshot
    tryaptinstall synergy
    tryaptinstall steam
    tryaptinstall keychain
    tryaptinstall code
    tryaptinstall youtube-dl
    tryaptinstall mpv
    tryaptinstall youtube-viewer
    tryaptinstall zathura
    tryaptinstall bat

    tryaptinstall minecraft-launcher
    tryaptinstall neovim
    tryaptinstall pdflatex
    tryaptinstall texlive-most
    tryaptinstall postman
    ###TODO Install Rider
fi
##TODO Windows



# Create symlinks
asklink ".bashrc" "/home/nan0scho1ar/dotfiles/.bashrc" "/home/nan0scho1ar/.bashrc"
#TODO this should be in .bash_aliases
asklink ".aliases" "/home/nan0scho1ar/dotfiles/.aliases" "/home/nan0scho1ar/.aliases"
asklink ".git_aliases" "/home/nan0scho1ar/dotfiles/.git_aliases" "/home/nan0scho1ar/.git_aliases"
asklink ".vimrc" "/home/nan0scho1ar/dotfiles/.vimrc" "/home/nan0scho1ar/.vimrc"
asklink ".xprofile" "/home/nan0scho1ar/dotfiles/.xprofile" "/home/nan0scho1ar/.xprofile"
asklink ".profile" "/home/nan0scho1ar/dotfiles/.profile" "/home/nan0scho1ar/.profile"
pwd
asklinkdir ".config" "/home/nan0scho1ar/dotfiles/.config" "/home/nan0scho1ar/.config"
asklinksudo "/etc/update-motd.d/10-help-text" "/home/nan0scho1ar/dotfiles/linux/99-banner" "/etc/update-motd.d/99-banner"
asklinksudo "/etc/hosts" "/home/nan0scho1ar/dotfiles/linux/hosts" "/etc/hosts"
#if ask "link .xmonad"; then
    #if [ -d ~/.xmonad ]; then
    tryaptinstall pandoc
    #fi
    #mkdir ~/.xmonad
    #ln ~/dotfiles/.xmonad/xmonad.hs ~/.xmonad/xmonad.hs

# Setup vim/nvim
## vim
if ask "Install vim/nvim plugins"; then
    if [ $NANOS_NAME = "linux" ]; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        vim -E -s +PlugInstall +visual +qall

	mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload
        cp ~/.vim/autoload/plug.vim \
            "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim
        nvim -E -s +PlugInstall +visual +qall
    fi
fi

#Git settings
if ask "Update git settings"; then
    git config --global pull.rebase false
    git config --global user.email "scorch267@gmail.com"
        #rm -r ~/.xmonad
    git config --global user.name "nan0scho1ar"
fi
