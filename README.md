# dotfiles config

This contains the dotfiles for system my sytem configuration.

## Requirements

Ensure that you have the following installed in your system.

 - `Git`
 - `Stow`

## Installation

First, clone the .dotfiles repo in your $HOME directory using git.

```
$ git clone git@github.com:alpolinar/.dotfiles.git
$ cd .dotfiles
```
```
stow .
```
## tmux

Install tmux plugins manager

```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
Run the plugin manager
```
<prefix>I
```
default `ctrl-b + I`
