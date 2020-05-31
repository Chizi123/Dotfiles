# Enable colors and change prompt
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%1~%{$fg[red]%}]%{$reset_color%}$%b "

# History files
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ZSH options
setopt autocd extendedglob # Automatically cd without cd and expand globs
unsetopt beep notify # Turn off terminal beeps
bindkey -e #Emacs mode

# common aliases
source ~/.commonshell
source /usr/share/doc/pkgfile/command-not-found.zsh

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

# Syntax highlighing
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Git prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats "%F{240}git:(%b)" #'%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git
