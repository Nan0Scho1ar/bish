

BISH_MUTAGENS=["fzy", "toml"]
BISH_PATH="$HOME/.config/bish"

splice() {
    echo "Splicing..."
    . "$1"
}

mutate() {
    splice $1
}

collect() {
    echo "Collecting..."
}

show_help() {
    echo "TODO Write help";
}

transpose() {
    echo "Transposing..."
}

transcribe() {

    echo "Transcribing..."
}

bish_read() {
    #idk if this is POSIX compliant
    local error=$([[ $? != 0 ]] && echo "[${red}✗${reset}]")
    local userathost="${yellow}$(whoami)${reset}@${cyan}$(hostname)${reset}"
    local dir="$yellow$(pwd)$reset"
    export BISH_PS1="$(echo -e $reset'┌─'$error'─['$userathost']─['$dir']\n└──╼ ')"
    read -p "$BISH_PS1" -e -r BISH_COMMAND;
    #idk if this is POSIX compliant
    #while [[ $BISH_COMMAND =~ [[:space:]]\\$ ]]; do
    while [[ $BISH_COMMAND =~ \\$ ]]; do
        printf "$BISH_PS2 ";
        BISH_COMMAND=$(echo $BISH_COMMAND $(read -e -r));
    done
    #TODO Replace newlines in multiline command before writing history
    echo $BISH_COMMAND >> ~/.config/bish/bish_history
}

init() {
    red=`tput setaf 1`;
    green=`tput setaf 2`;
    yellow=`tput setaf 3`;
    blue=`tput setaf 4`;
    magenta=`tput setaf 5`;
    cyan=`tput setaf 6`;
    white=`tput setaf 7`;
    blink=`tput blink`;
    reset=`tput sgr0`;
    export BISH_PS2=">"
    if [ -f ~/.config/bish/bish_history ]; then echo "exists"; fi
}


#process_input() {
    #bish_read
    #case $BISH_COMMAND in
        #"exit") exit ;;
        #"help") show_help ;;
        #*) bish_eval ;;
    #esac
#}

lex() {
    echo "Lexing..."
}

parse() {
    echo "Parsing..."
}

eval() {
    echo "Evaluating..."
}

bish_eval() {
    ./hist
}

#for file in ls: cat file
#for file in *: cat file
#for file in $(ls): cat file
#for file in `ls`: cat $file
#
#
#cd ~/repos/bish
#
#example():
#
#for file in * where $file not contains "#":
#    if extension == ".sh"
#    cat $file
#    prompt "Edit file?" && vim $file
#    replace -i "toma" with "hawk" in $file
#    sed -i "s/hawk/toma/gi" $file
#end
#
#for line in file in * where $file not contains "#":
#    echo $line
#end
#
#while true:
#
#    break


# Quotes
# $"[0-9]
# echo "test"
# echo $"0test1 $(echo $"1test2$"1)$"0
# echo $"0test1 $(echo $"1test2 $(echo $"2test3$"2)$"1)$"0

# Control Pipes
# echo test &|&  cat
# echo test |||  cat

# REDO
#
# !563..565
# becomes: !563; !564; !565;
#
# !563..565 > commands.bish
# !563.&.565
# !563.&&.565
# !563.&|&.565
# !563.|.565
# !563.||.565
# !563.|||.565
#
# >
# >>
# &>
# &>>
# <
# <<
#
# if [ x ]; then
# if x:
# for x in
# if dir not exists "~/repos/bish/":
# if file not exists "~/repos/bish/bish":
# if var not exists "filename"
# if func not exists "print()":
#
#
# !
# #
# $
# (
# )
# {
# }
# [
# ]
# |
# &
# '
# "
# `
# ;
# .
# +
# -
# /
# \
# *
# <
# >
#
