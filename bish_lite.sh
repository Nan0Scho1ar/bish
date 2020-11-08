#!/bin/sh
# BISH_LITE: The Minimal BioShell
# Author: Nan0Scho1ar (Christopher Mackinga)
# Created: 07/11/2020
# License: MIT License
# Self replicating shell script loader

bish() {
    [[ $1 = 'init' ]] && echo -e "bioshell v0.0.4" && return
    [[ $1 = 'splice' ]] && funcs="$funcs $1" && return
    [[ $1 != '' ]] && eval $* && return
    echo -e "#!/bin/sh\n# BISH: The BioShell\n# Generated: $(date)\n# License: MIT License\n"
    for func in $funcs; do type "$func" | tail -n +2 && echo; done
    echo -e "funcs=\"$funcs\"\nbish init" && return
}
funcs="bish"
bish init
