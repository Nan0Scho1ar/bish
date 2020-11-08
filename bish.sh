#!/bin/sh
# BISH: The BioShell
# Author: Nan0Scho1ar (Christopher Mackinga)
# Created: 07/10/2020
# License: MIT License
# Self replicating modular shell script loader

bish() (
    bish_init() { source "$(bish conf get "$BISH_SHELL.rc_path")" && echo -e "bioshell v0.0.4"; }
    bish_conf() { echo $BISH_CONFIG | toml "$2" "$3" "$4"; }
    bish_fetch() { source "$(curl "$(bish conf get "Mutagens.$2.remote")")"; }
    # TODO Check if any mutagens missing from conf
    # TODO Don't double dependencies if met elsewhere
    bish_mutate() { echo "TODO Mutate, fetch transcribe"; }
    bish_transcribe() {
        echo -e "#!/bin/sh\n# BISH: The BioShell\n# Generated: $(date)\n# License: MIT License\n"
        echo -e "bish() (\n    BISH_CONFIG=\$(cat << EOF\n${BISH_CONFIG}EOF\n)\n"
        for mutagen in $mutagens; do type "$mutagen" | tail -n +2 | sed "s/^\(.*$\)/    \1/" && echo; done
        echo -e '    bish $*\n)\nbish init'
    }
    bish() {
        toml -V > /dev/null || source $(curl "n0s1.sh/toml")
        [[ -z $BISH_CONFIG ]] && echo "Error, config variable not set" && return 1
        [[ -z $BISH_SHELL ]] && BISH_SHELL="$(awk -F: -v u="$USER" 'u==$1&&$0=$NF' /etc/passwd | sed 's|/bin/||')";
        [[ "$1" = "" ]] && bish_transcribe && return;
        mutagen="$(bish conf get_header_kv "command" "bish $1")";
        mutation=$(bish conf get "${mutagen}.function");
        echo "$mutation $*";
    }
    bish $*
)
bish init
