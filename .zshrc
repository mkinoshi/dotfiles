# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export PATH=$PATH:/usr/local/sbin
# Path to your oh-my-zsh installation.
export ZSH="/Users/makotokinoshita/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"

# Add powerline
ZSH_THEME="powerlevel9k/powerlevel9k"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir rbenv vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)

POWERLEVEL9K_PROMPT_ON_NEWLINE=true

# Add a space in the first prompt
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%f"
# Visual customisation of the second prompt line
local user_symbol="$"
if [[ $(print -P "%#") =~ "#" ]]; then
    user_symbol = "#"
fi
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%B%F{black}%K{yellow}%} $user_symbol%{%b%f%k%F{yellow}%} %{%f%}"

POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=’red’

# Colorise the top Tabs of Iterm2 with the same color as background
# Just change the 18/26/33 wich are the rgb values
echo -e "\033]6;1;bg;red;brightness;18\a"
echo -e "\033]6;1;bg;green;brightness;26\a"
echo -e "\033]6;1;bg;blue;brightness;33\a"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
function go-cover {
    t="/tmp/go-cover.$$.tmp"
    go test -coverprofile=$t $@ && go tool cover -html=$t && unlink $t
}

# function definitions
function local-bgoto {
  docker exec -it $(docker ps | grep backend | awk '{print $1}') bash
}

function local-dgoto {
  docker exec -it $(docker ps | grep postgres | awk '{print $1}') bash
}

function local-fgoto {
  docker exec -it $(docker ps | grep frontend | awk '{print $1}') bash
}

alias vesta-test="cypress open --project ~/Desktop/Dev/vesta/js_packages/web"
alias antcode-test="cypress open --project ~/Desktop/Dev/antcode/packages/web"
alias glog="git log --graph --decorate --name-status --all"
alias glist="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"
alias gclean="git branch | grep -v \* | xargs git branch -D"
alias docker-clean="docker rmi -f \$(docker images | grep \"^\" | awk \"{print \$3}\")"
alias tidal="~/Desktop/Dev/SuperCollider/build/editors/sc-ide/RelWithDebInfo/SuperCollider.app/Contents/MacOS/sclang ~/Desktop/Dev/SuperCollider/build/superdirt_startup.scd"
alias pgoto="pk exec -it $(pk get pods | grep verium-api | awk 'NR==1{print $1}') -c verium-api bash -- -c 'echo \$DATABASE_SECRET && pgcli postgres://\$DATABASE_USERNAME:\$DATABASE_SECRET@127.0.0.1:5432/vesta-prod'"
alias gblog="ssh root@167.99.96.159"
alias gblog-home="ssh root@165.22.98.149"
alias trunner="ssh -i tradeup.pem ubuntu@ec2-50-18-232-44.us-west-1.compute.amazonaws.com"
alias tvpn="ssh -i vpn.pem root@18.236.183.83"
alias ts="tkubectl --namespace tradeup-servers-staging"
alias tp="tkubectl --namespace tradeup-servers-prod"
alias watch='watch '

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/makotokinoshita/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/makotokinoshita/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/makotokinoshita/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/makotokinoshita/google-cloud-sdk/completion.zsh.inc'; fi

source /Users/makotokinoshita/.ghcup/env
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig:$PKG_CONFIG_PATH"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

# Pass rbenv to non system PATH
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

# Pass the path to flutter
export PATH=${HOME}/Desktop/Dev/flutter/bin:${PATH}

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:${HOME}/.local/share/solana/install/active_release/bin
export GOPATH=$(go env GOPATH)
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)




# krew path
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
