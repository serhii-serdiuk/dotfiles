# Editing CLAUDE.md and AGENTS.md

Applies to every instruction doc, this one included. A project's own "Editing this file"
section adds its specifics: how to verify, where facts live, which statements have twins.

- Record only what a reader cannot get from the code: traps, ordering constraints, measured
  costs, decisions. Skip whatever a comment, a header, `--help` or the source states plainly.
- Verify before writing. Do not document advertised-but-unimplemented behaviour, and do not
  generalise a number measured on one or two cases.
- Having verified something the hard way, put the mechanism in a comment next to the fix and
  record only the consequence in the doc. Ask what a reader would do differently knowing it;
  if the answer is nothing, it is a code comment.
- Write each entry as an instruction that stands on its own. A reader should not need to know
  what went wrong, who got it wrong, or which session prompted it — state the rule and stop.
  Rationale earns its place only when it changes how the rule is applied.
- One fact, one place. Search for a fact before stating it; if a comment, header or another
  section already covers it, point there — a copied fact becomes a contradiction as soon as
  one copy changes.
- Prefer a runnable command over prose describing it, with the caveats that make it work beside it.
- When adding or changing a rule, rewrite the older statement it supersedes instead of
  appending a qualifier — otherwise the doc contradicts itself.
- Leave out transient state: a bug about to be fixed, a current hardcoded value, a workaround
  you intend to remove.

# Code comments

- Match the surrounding code's comment density and style; don't over-comment. Never restate
  what names or code already say. Comment only what the code cannot express: the meaning of a
  magic value, an upstream or ordering constraint, or a decision that isn't visible locally.
- Keep comments short and in plain English, with no uncommon abbreviations or slang. Unless the
  surrounding code does otherwise, no trailing `.` on a single-sentence comment.
- Assume the reader is not a native speaker: prefer everyday verbs (*show, use, ask, query,
  wait, check, keep, replace*) to metaphors borrowed from electronics and networking (*gate,
  latch, poll, propagate, collapse, plumb, hook, fan out, short-circuit*), unless the word is
  the actual technical name (a git hook, polling an API).

# Git staging

**Never `git add` or `git commit` on your own initiative.** Stage only when I ask
for it in that message. An earlier "stage these changes" is *not* standing
authorisation: if I ask you to stage, and you then edit those files again, stop
and tell me — do not re-stage. Same when your own work leaves the index stale
(a rename, a deleted file): report it and give me the command, don't run it.

**When I do ask you to stage, stage only the hunks you changed in this session.**
My working tree usually carries my own in-flight work, often in the very files
you touched — shared registries, CMake lists and the like collect everyone's
changes at once. So check `git diff` per file before staging:

- Every hunk in the file is yours → `git add <path>`.
- The file also contains my changes → stage a blob of `git show HEAD:<path>`
  plus only your lines (`git add -p` is interactive and unavailable):

      git hash-object -w --path <path> --stdin        # prints <sha>
      git update-index --cacheinfo 100644,<sha>,<path>

Afterwards, confirm with `git diff --cached` that none of my identifiers leaked
in, and tell me the index now holds a partial version of those files — a
`git stash` or a checkout of the index would drop my lines.
