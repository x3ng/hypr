#!/usr/bin/env bash
set -euo pipefail

source_dir=$(dirname -- "$(realpath -- "$0")")
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/hypr
files=(hyprland.lua environment.lua compositor.lua monitor.lua appearance.lua
       binds.lua workspaces.lua rules.lua apps.lua startup.lua)
legacy=(settings.lua hyprlock.conf hyprpaper.conf hypridle.conf)
mode=${1:-install}
old_dir=

usage() {
    printf 'Usage: %s [install | migrate OLD_HYPR_DIR | uninstall]\n' "$0" >&2
    exit 2
}

owns_link() {
    [[ -L "$1" && $(readlink -- "$1") == "$2" ]]
}

case "$mode" in
    install|uninstall) [[ $# -le 1 ]] || usage ;;
    migrate)
        [[ $# -eq 2 && -n $2 ]] || usage
        # The old installer used absolute targets. Allow a former checkout
        # whose directory no longer exists, so dangling links can be migrated.
        old_dir=$(realpath -m -- "$2")
        [[ $old_dir != "$source_dir" && $old_dir != / ]] || usage
        ;;
    *) usage ;;
esac

if [[ $mode == uninstall ]]; then
    for file in "${files[@]}"; do
        target=$config_dir/$file
        if owns_link "$target" "$source_dir/$file"; then
            rm -- "$target"
            printf 'Removed %s\n' "$target"
        fi
    done
    exit 0
fi

# Check every target before changing any, including dangling foreign links.
for file in "${files[@]}"; do
    target=$config_dir/$file
    if [[ ! -f $source_dir/$file ]]; then
        printf 'Missing source file: %s\n' "$source_dir/$file" >&2
        exit 1
    fi
    if [[ ! -e $target && ! -L $target ]] || owns_link "$target" "$source_dir/$file"; then
        continue
    fi
    if [[ $mode == migrate ]] && owns_link "$target" "$old_dir/$file"; then
        continue
    fi
    printf 'Refusing to replace %s; no files changed.\n' "$target" >&2
    exit 1
done

mkdir -p -- "$config_dir"
for file in "${files[@]}"; do
    target=$config_dir/$file
    if owns_link "$target" "$source_dir/$file"; then
        continue
    elif [[ $mode == migrate ]] && owns_link "$target" "$old_dir/$file"; then
        ln -sfnT -- "$source_dir/$file" "$target"
    else
        ln -sT -- "$source_dir/$file" "$target"
    fi
    printf 'Linked %s\n' "$target"
done

if [[ $mode == migrate ]]; then
    for file in "${legacy[@]}"; do
        target=$config_dir/$file
        if owns_link "$target" "$old_dir/$file"; then
            rm -- "$target"
            printf 'Retired %s\n' "$target"
        fi
    done
fi
