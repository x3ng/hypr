#!/usr/bin/env bash
set -euo pipefail

repo=$(dirname -- "$(dirname -- "$(realpath -- "$0")")")
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
export HOME=$tmp/home XDG_CONFIG_HOME="$tmp/xdg config"
config=$XDG_CONFIG_HOME/hypr
old_dir=$tmp/former/hypr
installer=$repo/install.sh

expect_refusal() {
    if bash "$installer" "$@" >"$tmp/error" 2>&1; then
        printf 'Expected installer to refuse: %s\n' "$*" >&2
        exit 1
    fi
    grep -q 'Refusing to replace' "$tmp/error"
}

bash "$installer" install
[[ $(readlink "$config/hyprland.lua") == "$repo/hyprland.lua" ]]
[[ ! -e $HOME/.config ]]
bash "$installer" install
bash "$installer" uninstall
[[ ! -L $config/hyprland.lua ]]

ln -s "$old_dir/hyprland.lua" "$config/hyprland.lua"
ln -s "$old_dir/hypridle.conf" "$config/hypridle.conf"
ln -s "$tmp/foreign.conf" "$config/hyprlock.conf"
printf 'local file\n' > "$config/startup.lua"
expect_refusal install
expect_refusal migrate "$old_dir"
[[ $(readlink "$config/hyprland.lua") == "$old_dir/hyprland.lua" ]]
[[ $(cat "$config/startup.lua") == 'local file' && ! -L $config/binds.lua ]]
rm -- "$config/startup.lua"
ln -s "$tmp/foreign.lua" "$config/startup.lua"
expect_refusal migrate "$old_dir"
[[ $(readlink "$config/hyprland.lua") == "$old_dir/hyprland.lua" ]]
rm -- "$config/startup.lua"

bash "$installer" migrate "$old_dir"
[[ $(readlink "$config/hyprland.lua") == "$repo/hyprland.lua" ]]
[[ ! -L $config/hypridle.conf ]]
[[ $(readlink "$config/hyprlock.conf") == "$tmp/foreign.conf" ]]
rm -- "$config/startup.lua"
printf 'local file\n' > "$config/startup.lua"
bash "$installer" uninstall
[[ ! -L $config/hyprland.lua && $(cat "$config/startup.lua") == 'local file' ]]
[[ $(readlink "$config/hyprlock.conf") == "$tmp/foreign.conf" ]]
printf 'Installer: XDG paths, migration, conflicts and uninstall passed\n'
