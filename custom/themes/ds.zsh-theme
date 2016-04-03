# af-magic.zsh-theme
# Repo: https://github.com/andyfleming/oh-my-zsh
# Direct Link: https://github.com/andyfleming/oh-my-zsh/blob/master/themes/af-magic.zsh-theme
INSCOL=blue

# NORMAL mode color
NORMCOL=yellow

# REPLACE mode color
REPCOL=red

CURRENT_BG='NONE'

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n "%{$bg%F{$CURRENT_BG}%}%{$fg%}"
  else
    echo -n "%{$bg%}%{$fg%}"
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  [[ $? -ne 0 ]] && prompt_segment NONE default "%{%F{red}%}✗"
  [[ $UID -eq 0 ]] && prompt_segment NONE default "%{%F{yellow}%}!"
  [[ $(jobs -l | wc -l) -gt 0 ]] && prompt_segment NONE default "%{%F{cyan}%}&"
}

# Dir: current working directory
prompt_dir() {
  prompt_segment NONE blue '%~'
}

my_git_prompt() {
  tester=$(git rev-parse --git-dir 2> /dev/null) || return
  
  INDEX=$(git status --porcelain 2> /dev/null)
  STATUS=""

  # is anything staged?
  if $(echo "$INDEX" | command grep -E -e '^(D[ M]|[MARC][ MD]) ' &> /dev/null); then
      if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &> /dev/null); then
          STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED_UNSTAGED"
      else
          STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
      fi
  else 
      # is anything unstaged?
      if $(echo "$INDEX" | command grep -E -e '^[ MARC][MD] ' &> /dev/null); then
          STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
      else
          STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_NORMAL"
      fi
  fi

  if [[ -n $STATUS ]]; then
    STATUS=" $STATUS"
  fi

  echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

function current_branch() {
  local ref
  ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# Vi mode indicators
set_vi_mode() {
    case "$1" in
        "i")
            indcol=$INSCOL
            zsh_vi_mode="»"
            ;;
        "n")
            indcol=$NORMCOL
            zsh_vi_mode="«"
            ;;
        "r")
            indcol=$REPCOL
            zsh_vi_mode="»"
            ;;
    esac
    vim_mode="%{%F{$indcol}%}"
}

vi-edit-command-line() {
    set_vi_mode "i"
    edit-command-line
}
zle -N vi-edit-command-line

function zle-keymap-select {
if [ "$KEYMAP" = "vicmd" ]
then
    set_vi_mode "n"
else
    if [[ "$ZLE_STATE" = *overwrite* ]]
    then
        set_vi_mode "r"
    else
        set_vi_mode "i"
    fi
fi
zle reset-prompt
}
zle -N zle-keymap-select

function zle-line-finish {
    set_vi_mode "i"
}
zle -N zle-line-finish

function prompt_mode() {
    print -n "${vim_mode}${zsh_vi_mode}"
}

set_vi_mode "i"
# primary prompt
PROMPT='$FG[237]------------------------------------------------------------%{$reset_color%}
$(prompt_status)\
$(prompt_dir)\
$(my_git_prompt)\
$(prompt_mode)\
$(prompt_end)'

PROMPT2=' '
RPS1=' '
#%{$reset_color%}$(my_git_prompt)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}[%{$fg[blue]%}"
ZSH_THEME_GIT_PROMPT_NORMAL="%{$fg[blue]%}✓"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}✗"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg[red]%}✗"
ZSH_THEME_GIT_PROMPT_STAGED_UNSTAGED="%{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[yellow]%}]%{$reset_color%}"
