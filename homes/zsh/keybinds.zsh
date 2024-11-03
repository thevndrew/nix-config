# Make Ctrl-s search forward instead of freezeing the terminal
setopt no_flow_control

# enable some bash like bindings such a C-r reverse search
#bindkey -e

# bind start and end keys
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

bindkey "^[[3~" delete-char
