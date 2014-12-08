alias ll="ls -lGh"
alias la="ls -lAGh"
alias grep="grep --color=auto"
alias cd-="cd - >/dev/null"

alias reload!="exec $SHELL" # "[[ -f ~/.bashrc ]] && . ~/.bashrc"
alias alive="kits_proxy_alive; memp.alive"
alias af="alias | awk '{print substr(\$0,index(\$0, \" \")+1,length())}' | grep"

for _f in $(ls $KITS/shell/aliases/*.sh 2>/dev/null); do . $_f; done 
