#!/usr/bin/env bash
#
# Guard for instruction-doc edits (CLAUDE.md, AGENTS.md): puts the conventions for the target
# doc in front of the model at the moment it edits, whichever tool it uses. Two sections are
# injected, each matched at any heading level, so either may sit nested under another one:
#   - "Editing CLAUDE.md and AGENTS.md" from ~/.claude/CLAUDE.md: rules for every such doc;
#   - "Editing this file" from the target doc itself: its project-specific additions.
#
#   pre   PreToolUse  on Write|Edit|Bash — injects the rules before the edit.
#         Write/Edit are matched on file_path. Bash is matched on the command text
#         naming a doc together with a write-intent token, since a matcher cannot
#         inspect a command string. Read-only commands stay silent.
#   post  PostToolUse on Bash — compares a hash taken in the pre pass and injects
#         the rules if a watched doc actually changed. This is the backstop for an
#         edit the pre heuristic missed (an indirect path, a variable, a script).
#
# Both passes exit 0 and print nothing when they have nothing to say.

set -u

mode="${1:-pre}"
payload="$(cat)"

global_doc="$HOME/.claude/CLAUDE.md"
global_title="Editing CLAUDE.md and AGENTS.md"
local_title="Editing this file"

state_dir="${TMPDIR:-/tmp}/claude-md-guard"
mkdir -p "$state_dir" 2>/dev/null || true
# One state file per session; a session that ends between the two passes leaves
# its file behind, so drop anything older than a day.
find "$state_dir" -type f -mtime +1 -delete 2>/dev/null || true

jqp() { printf '%s' "$payload" | jq -r "$1" 2>/dev/null; }

# The instruction docs an edit in this session could plausibly touch.
watched_files() {
    printf '%s\n' "$PWD/CLAUDE.md" "$PWD/AGENTS.md" "$global_doc"
}

hash_watched() {
    local f real
    for f in $(watched_files); do
        [ -f "$f" ] || continue
        real="$(readlink -f "$f" 2>/dev/null || printf '%s' "$f")"
        printf '%s  %s\n' "$(cksum < "$real" | tr -s ' ' | cut -d' ' -f1)" "$real"
    done | sort -u
}

# Print the body of the section titled <title> in <file>, or nothing if there is none.
section_of() {  # section_of <file> <title>
    local file="$1" title="$2" section
    [ -f "$file" ] || return 1
    section="$(awk -v t="$title" '
        /^#+ / && substr($0, index($0, " ") + 1) == t { inside = 1; next }
        inside && /^#+ /                              { exit }
        inside                                        { print }
    ' "$file")"
    [ -n "${section//[[:space:]]/}" ] || return 1
    printf '%s' "$section"
}

emit() {  # emit <event> <preamble> <file>
    local event="$1" preamble="$2" file="$3" global own message
    global="$(section_of "$global_doc" "$global_title")" || global=""
    own="$(section_of "$file" "$local_title")" || own=""
    [ -n "$global$own" ] || return 0
    message="$preamble"
    [ -n "$global" ] && message+=$'\n\n'"Rules for every instruction doc (${global_doc}):"$'\n'"$global"
    [ -n "$own" ] && message+=$'\n\n'"Additions specific to ${file}:"$'\n'"$own"
    jq -n --arg e "$event" --arg ctx "$message" \
        '{hookSpecificOutput: {hookEventName: $e, additionalContext: $ctx}}'
    exit 0
}

tool="$(jqp '.tool_name // empty')"
session="$(jqp '.session_id // "nosession"')"
state_file="$state_dir/${session//[^A-Za-z0-9_-]/_}"

if [ "$mode" = post ]; then
    [ "$tool" = Bash ] || exit 0
    [ -f "$state_file" ] || exit 0
    before="$(cat "$state_file")"
    rm -f "$state_file"
    after="$(hash_watched)"
    [ "$before" = "$after" ] && exit 0
    # Report the first file that is in both snapshots and whose hash differs. A file that
    # only appears in one of them changed directory, not content, so it is not an edit.
    changed="$(printf '%s\n%s\n' "$before" "$after" | awk -v n="$(printf '%s\n' "$before" | grep -c .)" '
        NR <= n            { before[$2] = $1; next }
        ($2 in before) && before[$2] != $1 { print $2; exit }
    ')"
    [ -n "${changed:-}" ] || exit 0
    emit PostToolUse "You just changed ${changed} through a shell command. Check that edit against the rules for what belongs in it:" "$changed"
    exit 0
fi

case "$tool" in
    Write | Edit)
        file="$(jqp '.tool_input.file_path // empty')"
        case "$file" in
            */CLAUDE.md | CLAUDE.md | */AGENTS.md | AGENTS.md) ;;
            *) exit 0 ;;
        esac
        emit PreToolUse "Before writing to ${file}, these are the rules for what belongs in it:" "$file"
        ;;
    Bash)
        cmd="$(jqp '.tool_input.command // empty')"
        # Record a baseline for the post pass regardless of what the command looks like.
        hash_watched > "$state_file" 2>/dev/null || true
        case "$cmd" in
            *CLAUDE.md*|*AGENTS.md*) ;;
            *) exit 0 ;;
        esac
        # Redirections to /dev/null and fd duplications (2>/dev/null, &>/dev/null, 2>&1, >&2)
        # cannot write a doc; drop them so they do not count as write intent.
        probe="$(printf '%s' "$cmd" | sed -E 's#[0-9&]?>>?[[:space:]]*/dev/null##g; s#[0-9]*>&[0-9-]+##g')"
        # Write intent: redirection, in-place sed, tee, a python/perl write, a copy or move.
        case "$probe" in
            *">"*|*"tee "*|*"sed -i"*|*"-i.bak"*|*".write("*|*"open("*|*"mv "*|*"cp "*|*"truncate"*|*"patch "*) ;;
            *) exit 0 ;;
        esac
        # Target the doc paths the command names; a bare or relative name resolves against
        # $PWD, so one behind a `cd` is missed here and left to the post pass.
        for token in $(printf '%s' "$probe" | grep -oE "[^[:space:]'\"=<>|;&()]*(CLAUDE|AGENTS)\.md" | sort -u); do
            case "$token" in
                /*)    f="$token" ;;
                "~/"*) f="$HOME/${token#\~/}" ;;
                *)     f="$PWD/$token" ;;
            esac
            [ -f "$f" ] || continue
            emit PreToolUse "This command looks like it edits ${f}. These are the rules for what belongs in it:" "$f"
        done
        ;;
esac
exit 0
