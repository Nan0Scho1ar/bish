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
            remote = "bish.sh/bish.sh"
            command = "bish"
        [Genes.bish.Depends]
            [Genes.bish.Depends.toml]
                description = "Read and write toml files"
                remote = "n0s1.sh/toml"
                command = "toml"
                use_existing = true
        [Genes.bish.SubMutations]
            [Genes.bish.SubMutations.bish_conf]
                description = "Various tools for working with bish config"
                remote = "n0s1.sh/bish_conf"
                function = "bish_conf"
                command = "bish conf"
            [Genes.bish.SubMutations.bish_transcribe]
                description = "Write bish, config and mutations to a file"
                remote = "n0s1.sh/bish_transcribe"
                function = "bish_transcribe"
                command = "bish transcribe"
            [Genes.bish.SubMutations.bish_layers]
                description = "Load different script layers using bish"
                remote = "n0s1.sh/bish_layers"
                function = "bish_layers"
                command = "bish layers"

    [Genes.n0s1]
        [Genes.n0s1.core]
            [Genes.n0s1.core.toml]
                description = ""
                remote = "n0s1.sh/toml"
                command = "toml"
                [Genes.n0s1.core.toml.Depends]
                    [Genes.n0s1.core.toml.Depends.exprq]
                        description = ""
                        remote = "n0s1.sh/exprq"
                        command = "exprq"
                        use_existing = true
            [Genes.n0s1.core.exprq]
                    description = "Evaluate regex cleanly"
                    remote = "n0s1.sh/exprq"
                    command = "exprq"
            [Genes.n0s1.core.fzy]
                    description = "Small command line fuzzy finder"
                    remote = "n0s1.sh/fzy"
                    command = "fzy"
            [Genes.n0s1.core.convert]
                    description = "Easily convert between different mediums"
                    remote = "n0s1.sh/convert"
                    command = "convert"
            [Genes.n0s1.core.extract]
                    description = "Easily extract many types of archives with one cmd"
                    remote = "n0s1.sh/extract"
                    command = "extract"
        [Genes.n0s1.git_manange]
            description = "Easily manage multiple git repositories"
            remote = "n0s1.sh/git_manange"
            command = "gm"
        [Genes.n0s1.g]
            description = "Quick shortcuts for common git commands"
            remote = "n0s1.sh/g"
            command = "g"

    [Genes.z]
        description = "Quickly navigate to recent/commonly accessed directories"
        remote = "n0s1.sh/z"
        command = "z"

    [Genes.bliss]
        description = "Bioshell LISp Syntax"
        remote = "bish.sh/bliss"
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
    bish_init() { source "$(bish_conf get "$BISH_SHELL.rc_path")" || echo "source failed: \$BISH_SHELL not set"; echo -e "bioshell v0.0.4"; }
                                        #TODO Fix sh version
    bish_conf() { echo "$BISH_CONFIG" | toml.py "$1" "$2" "$3"; }
    bish_fetch() { source "$(curl "$(bish_conf get "Genes.$2.remote")")"; }
    # TODO Check if any genes missing from conf
    # TODO Don't double dependencies if met elsewhere
    bish_mutate() { echo "TODO Mutate, fetch transcribe"; }
    bish_transcribe() {
        genes="$(bish_conf get_headers Genes | sed -n '/Depends/d;/SubMutations/d;s/.*\.command="\(.*\)"/\1/p')"
        echo -e "#!/bin/sh\n# BISH: The BioShell\n# Generated: $(date)\n# License: GPL v3\n"
        echo -e "BISH_CONFIG=\"\$(cat << EOF\n${BISH_CONFIG}\nEOF\n)\"\n"
        for gene in $genes; do type $gene | tail -n +2 && echo; done
        echo -e "\nbish init"
    }
    bish_run() {
        #TODO Fix sh version
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
        #gene="$(bish_conf get_header_kv "command" "bish $1")";
        #mutation=$(bish_conf get "${gene}.function");
        #echo "$mutation $*";
    }
    if [ $# -eq 0 ]; then bish_transcribe 2>/dev/null
    else
        bish_run $*
    fi
)

exprq() { expr "$1" : "$2" 1>/dev/null; }

#TODO Write this in a sane way (temp replaced with toml.py)
toml() {
    case $1 in
        '-V') echo "toml v0.0.2" ;;
        *) lines="$(echo "$(< /dev/stdin)")" ;;
            #lines="$(cat "$1")" ;;
    esac
    parent="$(echo $3 | sed 's/\(.*\)\.\(.*\)/\1/')"
    key="$(echo $3 | sed 's/\(.*\)\.\(.*\)/\2/')"
    value="$4"
    if [ $1 = "get" ]; then
        #Global
        if exprq "$parent" "$key"; then
            echo "$lines" | sed -n "/\\[.*\\]/q;p" | \
            # TODO support multiline arrays
                sed -n "s/^\s*$key=\(.*\)/\1/p"
        # Filter to subheading then get value
        else
            echo "$lines" | sed -n "/^\s*\[$parent\]/,/\[.*\]/{//!p;}" | \
                # TODO support multiline arrays
                sed -n "s/^\s*$key=\(.*\)/\1/p"
        fi

    if [ $1 = "get_headers" ]; then
        #Global
        echo "$lines" | sed -n "/^\s*\[$parent\]/,/\[.*\]/{//!p;}" | \
            # TODO support multiline arrays
            sed -n "s/^\s*$key=\(.*\)/\1/p"
    fi

    #TODO Fix file indenting
    elif [ $1 = "set" ]; then
        if exprq "$parent" "$key"; then
            updated=false
            echo "$lines" | sed -n "/\\[.*\\]/q;p" | \
            while read line; do
                if exprq "$line" "$key=.*"; then
                    echo "$key=$value";
                    updated=true;
                    continue;
                fi
                echo $line;
            done
            $updated || echo "$key=$value";
            echo "$lines" | sed -n "/\\[.*\\]/,/EOF/p"
        else
            in_parent=false
            # try to update value for existing header
            cat "$2" | while read line; do
                exprq "$line" "\\[.*\\]" && in_parent=false;
                # Set in_parent if currently inside correct header
                exprq "$line" "\\[$parent\\]" && in_parent=true;
                if $in_parent; then
                    # Write new value if existing key found
                    if exprq "$line" "$key=.*"; then
                        echo "$key=$value";
                        in_parent=false;
                        continue;
                        # Write new value if existing key not found
                        # before entering next header
                    elif exprq "$line" "\\[.*\\]" && \
                        ! exprq "$line" "\\[$parent\\]"; then
                            echo "$key=$value";
                            in_parent=false;
                    fi
                fi
                echo $line;
            done;
            # If the header doesn't exist add it and the value
             if ! echo "$lines" | grep -q "\\[$parent\\]"; then
                # TODO Recursively look for parent headers not dump
                # at bottom of file
                echo "[$parent]" >> $2 && echo "$key=$value" >> $2
                return
            fi
        fi
    fi
}

bish init
