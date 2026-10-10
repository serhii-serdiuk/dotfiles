#!/bin/bash
# Run stow_dotfiles from setup/aux/restore-configs.sh twice in a throwaway home and show the result.
# Usage: test-stow-dotfiles.sh [file-in-home...]
# Each argument is created in the throwaway home as a plain file before the first run,
# to check that it is kept as .bak.

set -e

repo=$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)
test_home=$(mktemp -d)
trap 'rm -rf "$test_home"' EXIT

for file in "$@"; do
    mkdir -p "$test_home/$(dirname "$file")"
    echo "existing $file" > "$test_home/$file"
done

# Only the function is taken: sourcing the whole script would run the setup steps
stow_function=$(sed -n '/^stow_dotfiles()/,/^}/p' "$repo/setup/aux/restore-configs.sh")

for run in 1 2; do
    echo "=== run $run"
    HOME=$test_home SETUP_DIR=$repo/setup bash -ec "log() { :; }; $stow_function; stow_dotfiles"
done

echo "=== links in throwaway home"
(cd "$test_home" && find . -type l | sort | while read -r link; do
    echo "$link -> $(realpath --relative-to="$repo" "$(readlink -f "$link")")"
done)
echo "=== real directories"
(cd "$test_home" && find . -mindepth 1 -type d | sort)
echo "=== backups"
(cd "$test_home" && find . -name '*.bak' | sort)
