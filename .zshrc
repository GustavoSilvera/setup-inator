# just git clone these into this location and source them here
# source $HOME/.zsh/spaceship/spaceship.zsh # too slow!
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOME/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

##############################################################################
# History Configuration
##############################################################################
HISTSIZE=5000               #How many lines of history to keep in memory
HISTFILE=$HOME/.zsh_history #Where to save history to disk
SAVEHIST=50000              #Number of history entries to save to disk
#HISTDUP=erase               #Erase duplicates in the history file
setopt    appendhistory     #Append history to the history file (no overwriting)
setopt    sharehistory      #Share history across terminals
setopt    incappendhistory  #Immediately append to the history file, not just when a term is killed

# >>> conda initialize >>>
if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/anaconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniconda3/etc/profile.d/conda.sh"
elif [ -d "$HOME/anaconda3" ]; then
    export PATH="$HOME/anaconda3/bin:$PATH"
elif [ -d "$HOME/miniconda3" ]; then
    export PATH="$HOME/miniconda3/bin:$PATH"
fi

# colourful ls
alias ls="ls --color=auto"
alias ll="ls -l --color=auto"

# automatic cd
# https://zsh.sourceforge.io/Intro/intro_16.html
setopt autocd

# make ctrl+arrow keys work in terminal
# https://serverfault.com/questions/386871/getting-5d-when-hitting-ctrl-arrow-key-in-a-terminal-on-freebsd
case "${TERM}" in
  cons25*|linux) # plain BSD/Linux console
    bindkey '\e[H'    beginning-of-line   # home 
    bindkey '\e[F'    end-of-line         # end  
    bindkey '\e[5~'   delete-char         # delete
    bindkey '[D'      emacs-backward-word # esc left
    bindkey '[C'      emacs-forward-word  # esc right
    ;;
  *rxvt*) # rxvt derivatives
    bindkey '\e[3~'   delete-char         # delete
    bindkey '\eOc'    forward-word        # ctrl right
    bindkey '\eOd'    backward-word       # ctrl left
    # workaround for screen + urxvt
    bindkey '\e[7~'   beginning-of-line   # home
    bindkey '\e[8~'   end-of-line         # end
    bindkey '^[[1~'   beginning-of-line   # home
    bindkey '^[[4~'   end-of-line         # end
    ;;
  *xterm*) # xterm derivatives
    bindkey '\e[H'    beginning-of-line   # home
    bindkey '\e[F'    end-of-line         # end
    bindkey '\e[3~'   delete-char         # delete
    bindkey '\e[1;5C' forward-word        # ctrl right
    bindkey '\e[1;5D' backward-word       # ctrl left
    # workaround for screen + xterm
    bindkey '\e[1~'   beginning-of-line   # home
    bindkey '\e[4~'   end-of-line         # end
    ;;
  screen)
    bindkey '^[[1~'   beginning-of-line   # home
    bindkey '^[[4~'   end-of-line         # end
    bindkey '\e[3~'   delete-char         # delete
    bindkey '\eOc'    forward-word        # ctrl right
    bindkey '\eOd'    backward-word       # ctrl left
    bindkey '^[[1;5C' forward-word        # ctrl right
    bindkey '^[[1;5D' backward-word       # ctrl left
    ;;
esac

# make nice prompt
# https://wiki.archlinux.org/title/zsh
PROMPT='%F{2}%n%f@%F{5}%m%f %F{4}%B%~%b%f %# '

# add elapsed time to (right side) prompt
# https://gist.github.com/knadh/123bca5cfdae8645db750bfb49cb44b0
function preexec() {
  timer=$(print -P %D{%s%3.})
}

function precmd() {
  if [ $timer ]; then
    local now=$(print -P %D{%s%3.})
    local d_ms=$(($now-$timer))
    local d_s=$((d_ms / 1000))
    local ms=$((d_ms % 1000))
    local s=$((d_s % 60))
    local m=$(((d_s / 60) % 60))
    local h=$((d_s / 3600))
    if ((h > 0)); then elapsed=${h}h${m}m
    elif ((m > 0)); then elapsed=${m}m${s}s
    elif ((s >= 10)); then elapsed=${s}.$((ms / 100))s
    elif ((s > 0)); then elapsed=${s}.$((ms / 10))s
    else elapsed=${ms}ms
    fi

    export RPROMPT='[%F{3}%?%f]' # get success/failure
    export RPROMPT="$RPROMPT | %F{cyan}${elapsed} %{$reset_color%}"
    unset timer
  fi
}

# adress capitalization errors
# https://superuser.com/questions/1092033/how-can-i-make-zsh-tab-completion-fix-capitalization-errors-for-directories-and
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
