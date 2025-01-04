# dotfiles config
This contains the dotfiles for system my sytem configuration.

## Requirements
Ensure that you have the following installed in your system.
 - `git`
 - `stow`
 - `unzip`
 - `fish`
 - `kitty`
 - `fzf`
 - `zoxide`
 - `ripgrep`
 - `neovim`
 - `tmux`
 - `yazi`
 - `starship`
 - `bat`
 - `eza`
 - `fisher`
 - `bass`

## Installation
First, clone the repo in your `$HOME` directory using git.
```
git clone git@github.com:alpolinar/.dotfiles.git
cd .dotfiles
```
### Example
```
stow fish
```
## tmux
Install tmux plugins manager.
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
Run the plugin manager.
```
<prefix>I
```
default `ctrl-b + I`

## neovim
To install `mason LSP`, make sure `npm` is installed either via `nvm` (preferred) or install `NodeJS` and `npm` manually.

## fish
Fish config requires [bass](https://github.com/edc/bass) to add `nvm` to path. Install [fisher](https://github.com/jorgebucaran/fisher) fish plugin manager to install it. 
