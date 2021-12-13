# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable colors and change prompt
#autoload -U colors && colors	# Load colors
#PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%1~%{$fg[red]%}]%(?:%{$fg[white]%}$:%{$fs_bold[red]%}<%?>$)%{$reset_color%}%b "

# Git prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats "%F{240}git:(%b)"
zstyle ':vcs_info:*' enable git

# History files
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ZSH options
setopt autocd extendedglob correct_all # Automatically cd without cd and expand globs
unsetopt beep notify # Turn off terminal beeps
bindkey -e #Emacs mode

# common shell options
source ~/.commonshell

# Command not found. Works with pkgfile in Arch
[ -f /usr/share/doc/pkgfile/command-not-found.zsh ] && source /usr/share/doc/pkgfile/command-not-found.zsh

# Make the delete key work normally
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char

# Disable ctrl-s to freeze terminal
stty stop undef

# Set terminal title
precmd() {print -Pn "\e]0;%n@%M:%~\a"}

# Completion stuff, generated from the install
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' max-errors 3 numeric
zstyle ':completion:*' menu select=1
zstyle ':completion:*' prompt 'Change to "%e"'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' verbose true
zstyle ':completion::complete:*' gain-privileges 1
zstyle :compinstall filename '/home/joel/.zshrc'

autoload -Uz compinit
compinit

# Plugins with antigen
if [ -f ~/.zsh/antigen/bin/antigen.zsh ]; then
    ADOTDIR=~/.zsh
    _ANTIGEN_INSTALL_DIR=~/.zsh/antigen
    # ANTIGEN_LOG=~/log
    source ~/.zsh/antigen/bin/antigen.zsh

    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle zsh-users/zsh-autosuggestions
    antigen bundle zsh-users/zsh-completions
    antigen theme romkatv/powerlevel10k

    antigen apply
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.zsh/p10k.zsh ]] || source ~/.zsh/p10k.zsh
