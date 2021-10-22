#!/bin/bash
# BISH: The BioShell
# Author: Nan0Scho1ar (Christopher Mackinga)
# Created: 07/10/2020
# License: GPL v3
# Self replicating modular shell script loader

BISH_CONFIG="$(cat << EOF

[bash]
rc_path = "$HOME/repos/me/dotfiles/.bashrc"

[bish]
home = "$HOME/.config/bish"

[zsh]
rc_path = "$HOME/repos/me/dotfiles/.zshrc"

# New Genes (functions) should be defined here
[Genes]
    [Genes.bish]
            description = "Bish the BioShell"
            remote = "https://bish.sh/bish.sh"
            command = "bish"
        [Genes.bish.Depends]
            [Genes.bish.Depends.toml]
                description = "Read and write toml files"
                remote = "https://n0s1.sh/toml"
                command = "toml"
                use_existing = true
        [Genes.bish.SubMutations]
            [Genes.bish.SubMutations.bish_conf]
                description = "Various tools for working with bish config"
                function = "bish_conf"
                command = "bish conf"
            [Genes.bish.SubMutations.bish_transcribe]
                description = "Write bish, config and mutations to a file"
                function = "bish_transcribe"
                command = "bish transcribe"
            [Genes.bish.SubMutations.bish_layers]
                description = "Load different script layers using bish"
                function = "bish_layers"
                command = "bish layers"

    [Genes.n0s1]
        [Genes.n0s1.core]
            [Genes.n0s1.core.toml]
                description = ""
                remote = "https://n0s1.sh/toml"
                command = "toml"
                [Genes.n0s1.core.toml.Depends]
                    [Genes.n0s1.core.toml.Depends.exprq]
                        description = ""
                        remote = "https://n0s1.sh/exprq"
                        command = "exprq"
                        use_existing = true
            [Genes.n0s1.core.exprq]
                    description = "Evaluate regex cleanly"
                    remote = "https://n0s1.sh/exprq"
                    command = "exprq"
            [Genes.n0s1.core.fzy]
                    description = "Small command line fuzzy finder"
                    remote = "https://n0s1.sh/fzy"
                    command = "fzy"
            [Genes.n0s1.core.convert]
                    description = "Easily convert between different mediums"
                    remote = "https://n0s1.sh/convert"
                    command = "convert"
            [Genes.n0s1.core.extract]
                    description = "Easily extract many types of archives with one cmd"
                    remote = "https://n0s1.sh/extract"
                    command = "extract"
        [Genes.n0s1.git_manange]
            description = "Easily manage multiple git repositories"
            remote = "https://n0s1.sh/git_manange"
            command = "gm"
        [Genes.n0s1.g]
            description = "Quick shortcuts for common git commands"
            remote = "https://n0s1.sh/g"
            aliases = "g"

    [Genes.z]
        description = "Quickly navigate to recent/commonly accessed directories"
        remote = "https://n0s1.sh/z"
        command = "z"

    [Genes.bliss]
        description = "Bioshell LISp Syntax"
        remote = "https://bish.sh/bliss"
        command = "bliss"

[Layers]

    [Layers.Normal]
        [Layers.Normal.Genes]
            [Layers.Normal.Genes.bish]
                load=true

                [Layers.Normal.Genes.bish.SubMutations]
                    [Layers.Normal.Genes.bish.SubMutations.bish_conf]
                        load=true

                    [Layers.Normal.Genes.bish.SubMutations.bish_transcribe]
                        load=true

                    [Layers.Normal.Genes.bish.SubMutations.bish_layers]
                        load=true

            [Layers.Normal.Genes.n0s1]
                [Layers.Normal.Genes.n0s1.core]
                    [Layers.Normal.Genes.n0s1.core.toml]
                        load=true

                    [Layers.Normal.Genes.n0s1.core.exprq]
                        load=true

                    [Layers.Normal.Genes.n0s1.core.fzy]
                        load=true

                    [Layers.Normal.Genes.n0s1.core.convert]
                        load=true

                [Layers.Normal.Genes.n0s1.git_manange]
                    load=true

                [Layers.Normal.Genes.n0s1.g]
                    load=true

            [Layers.Normal.Genes.z]
                load=true

            [Layers.Normal.Genes.bliss]
                load=true

# You should not need to touch this.
[State]
    layer="Normal"

# Do not change this
EOF
)"

bish() (
    bish_init() { source "$(bish_conf get_value "$BISH_SHELL.rc_path")" || echo "source failed: \$BISH_SHELL not set"; echo -e "bioshell v0.3.1"; }
    bish_conf() { echo "$BISH_CONFIG" | toml "$1" "$2" "$3"; }
    # TODO prompt before sourcing (similar to AUR pkg)
    # TODO Allow choosing curl or wget
    bish_fetch() { curl -fLO "$(bish_conf get_value "Genes.$1.remote")" > "$2"; }
    # TODO Check if any genes missing from conf
    # TODO Don't double dependencies if met elsewhere
    bish_mutate() {
        echo "TODO Mutate. fetch then transcribe";
        bish_home=$(bish_conf get_value bish.home)
        mkdir -p $bish_home/genes
        genes="$(bish_conf get Genes | sed -n '/Depends/d;/SubMutations/d;s/Genes\.\(.*\)\.command=".*"/\1/p')"
        for gene in $genes; do
            echo "Fetching $gene";
            bish_fetch "$gene" "$bish_home/genes/$gene"
            cat  "$bish_home/genes/$gene"
            read -p "Source file? [y/n]"
            if [[ $REPLY = "Y|y" ]]; then
                source  "$bish_home/genes/$gene"
            fi
        done
    }
    # TODO Transcribe alias files (not just commands)
    bish_transcribe() {
        genes="$(bish_conf get Genes | sed -n '/Depends/d;/SubMutations/d;s/.*\.command="\(.*\)"/\1/p')"
        echo -e "#!/bin/sh\n# BISH: The BioShell\n# Generated: $(date)\n# License: GPL v3\n"
        echo -e "BISH_CONFIG=\"\$(cat << EOF\n${BISH_CONFIG}\nEOF\n)\"\n"
        for gene in $genes; do type $gene | tail -n +2 && echo; done
        echo -e "\nbish init"
    }
    bish_run() {
        toml -V > /dev/null || source $(curl "n0s1.sh/toml")
        [[ -z $BISH_CONFIG ]] && echo "Error, config variable not set" && return 1
        [[ -z $BISH_SHELL ]] && BISH_SHELL="$(awk -F: -v u="$USER" 'u==$1&&$0=$NF' /etc/passwd | sed 's|/bin/||')";
        case "$1" in
            "transcribe") bish_transcribe 2>/dev/null ;;
            "errors") bish_transcribe 1>/dev/null ;;
            "init") bish_init ;;
            "config") shift; bish_conf $* ;;
            "mutate") shift; bish_mutate $* ;;
            "fetch") shift; bish_fetch $* ;;
            *) echo "Unknown option";;
        esac
        #gene="$(bish_conf get "command" "bish $1")";
        #mutation=$(bish_conf get_value "${gene}.function");
        #echo "$mutation $*";
    }
    if [ $# -eq 0 ]; then bish_transcribe 2>/dev/null
    else
        bish_run $*
    fi
)

toml() {
    flatten() {
        comment_regex="^\s*#"
        header_regex="\s*\[.*\]"
        value_regex="\s*.*=.*"
        extract_header="s/\[//g; s/\]//g; s/ //g; s/\t//g; s/\n//g"
        extract_value="s/^\s*//; s/\t//g; s/\n//; s/ =/=/; s/= /=/"

        parent=""
        while IFS= read -r line; do
            if [[ $line =~ $comment_regex ]]; then
                continue
            elif [[ $line =~ $header_regex ]]; then
                parent=$(sed "$extract_header" <<< "$line")
            elif [[ $line =~ $value_regex ]]; then
                echo "$parent.$(sed "$extract_value" <<< "$line")"
            fi
        done < <(cat /dev/stdin)
    }

    #Returns the first value which matches the header
    get_value() {
        match="$1=.*"
        while IFS= read -r line; do
            if [[ $line =~ $match ]]; then
                sed "s/^.*=//" <<< "$line" | tr -d '"'
                break
            fi
        done < <(cat /dev/stdin | flatten)
    }

    # Returns all headers and values matching the input
    get() {
        match="^$1.*"
        while IFS= read -r line; do
            if [[ $line =~ $match ]]; then
                echo "$line"
            fi
        done < <(cat /dev/stdin | flatten)
    }

    case "$1" in
        "get") cat /dev/stdin | get "$2" ;;
        "get_value") cat /dev/stdin | get_value "$2" ;;
        "-V") echo "toml: version 0.7.1" ;;
        *) echo "Error: Unknown option";;
    esac
}

bish init
