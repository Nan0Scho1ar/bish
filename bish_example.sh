#!/bin/sh
# BISH: The BioShell
# Author: Nan0Scho1ar (Christopher Mackinga)
# Created: 07/10/2020
# License: MIT License
# Self replicating modular shell script loader

BISH_CONFIG=$(cat << EOF
[bash]
rc_path = "$HOME/dotfiles/.bashrc"

[bish]
home = "$HOME/.config/bish"

[zsh]
rc_path = "$HOME/dotfiles/.zshrc"



# New Mutagens (functions) should be defined here
[Mutagens]
    [Mutagens.bish]
        [Mutagens.bish.Depends]
            [Mutagens.bish.Depends.toml]
                description = "Read and write toml files"
                remote = "n0s1.sh/toml"
                command = "toml"
                use_existing = true
        [Mutagens.bish.SubMutations]
            [Mutagens.bish.SubMutations.bish_conf]
                description = "Various tools for working with bish config"
                remote = "n0s1.sh/bish_conf"
                function = "bish_conf"
                command = "bish conf"
            [Mutagens.bish.SubMutations.bish_transcribe]
                description = "Write bish, config and mutations to a file"
                remote = "n0s1.sh/bish_transcribe"
                function = "bish_transcribe"
                command = "bish transcribe"
            [Mutagens.bish.SubMutations.bish_layers]
                description = "Load different script layers using bish"
                remote = "n0s1.sh/bish_layers"
                function = "bish_layers"
                command = "bish layers"

    [Mutagens.n0s1]
        [Mutagens.n0s1.core]
            [Mutagens.n0s1.core.toml]
                description = ""
                remote = "n0s1.sh/toml"
                command = "toml"
                [Mutagens.n0s1.core.toml.Depends]
                    [Mutagens.n0s1.core.toml.Depends.exprq]
                        description = ""
                        remote = "n0s1.sh/exprq"
                        command = "exprq"
                        use_existing = true
            [Mutagens.n0s1.core.exprq]
                    description = "Evaluate regex cleanly"
                    remote = "n0s1.sh/exprq"
                    command = "exprq"
            [Mutagens.n0s1.core.fzy]
                    description = "Small command line fuzzy finder"
                    remote = "n0s1.sh/fzy"
                    command = "fzy"
            [Mutagens.n0s1.core.convert]
                    description = "Easily convert between different mediums"
                    remote = "n0s1.sh/convert"
                    command = "convert"
            [Mutagens.n0s1.core.extract]
                    description = "Easily extract many types of archives with one cmd"
                    remote = "n0s1.sh/extract"
                    command = "extract"
        [Mutagens.n0s1.git_manange]
            description = "Easily manage multiple git repositories"
            remote = "n0s1.sh/git_manange"
            command = "gm"
        [Mutagens.n0s1.g]
            description = "Quick shortcuts for common git commands"
            remote = "n0s1.sh/g"
            command = "g"

    [Mutagens.z]
        description = "Quickly navigate to recent/commonly accessed directories"
        remote = "n0s1.sh/z"
        command = "z"

[Layers]
    [Layers.Normal]
        [Layers.Normal.Mutagens]
            [Layers.Normal.Mutagens.bish]
                load=true

                [Layers.Normal.Mutagens.bish.SubMutations]
                    [Layers.Normal.Mutagens.bish.SubMutations.bish_conf]
                        load=true

                    [Layers.Normal.Mutagens.bish.SubMutations.bish_transcribe]
                        load=true

                    [Layers.Normal.Mutagens.bish.SubMutations.bish_layers]
                        load=true

            [Layers.Normal.Mutagens.n0s1]
                [Layers.Normal.Mutagens.n0s1.core]
                    [Layers.Normal.Mutagens.n0s1.core.toml]
                        load=true

                    [Layers.Normal.Mutagens.n0s1.core.exprq]
                        load=true

                    [Layers.Normal.Mutagens.n0s1.core.fzy]
                        load=true

                    [Layers.Normal.Mutagens.n0s1.core.convert]
                        load=true

                [Layers.Normal.Mutagens.n0s1.git_manange]
                    load=true

                [Layers.Normal.Mutagens.n0s1.g]
                    load=true

            [Layers.Normal.Mutagens.z]
                load=true

# You should not need to touch this.
[State]

EOF
)

bish() (
    bish_init() { source "$(bish conf get "$BISH_SHELL.rc_path")" && echo -e "bioshell v0.0.4"; }
    bish_conf() { echo $BISH_CONFIG | toml "$2" "$3" "$4"; }
    bish_fetch() { source "$(curl "$(bish conf get "Mutagens.$2.remote")")"; }
    # TODO Check if any mutagens missing from conf
    # TODO Don't double dependencies if met elsewhere
    bish_mutate() { echo "TODO Mutate, fetch transcribe"; }
    bish_transcribe() {
echo bang
        mutagens="$(bish conf get_headers Mutagens)"
        echo -e "#!/bin/sh\n# BISH: The BioShell\n# Generated: $(date)\n# License: MIT License\n"
        echo -e "BISH_CONFIG=\$(cat << EOF\n${BISH_CONFIG}EOF\n)\n"
        for mutagen in $mutagens; do type $mutagen | tail -n +2 && echo; done
        echo -e "\nbish init"
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

exprq() { expr "$1" : "$2" 1>/dev/null; }

toml() {
    case $1 in
        '-V') echo "toml v0.0.2" ;;
        '') lines="$(echo "$(< /dev/stdin)")" ;;
        *)  lines="$(cat "$1")" ;;
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
