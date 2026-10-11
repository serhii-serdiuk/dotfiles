---
name: add-stow-package
description: Add config files from $HOME to this dotfiles repo as a new stow package, or add files to an existing package. Use when the user wants to move, adopt or manage a config file or directory with stow, or create a new package.
---

# Add a stow package

A package is a top-level directory whose contents mirror `$HOME`: `<package>/<path>` is linked to `~/<path>`. Work through the steps in order. This skill stages and commits its own changes (step 7); that is the user's standing permission for this workflow only.

## 1. Check what goes in

Read every file before moving it.

- **Secrets:** run `gitleaks detect --no-git --source <path>` on each file (newer gitleaks: `gitleaks dir <path>`). Keep keys, tokens and credential stores out of the repo, even when gitleaks finds nothing.
- **Machine- or work-specific content:** absolute paths, hostnames, project variables. Ask the user whether they belong in this repo.
- **Files, not directories, when the app also writes there** (history, caches, sessions, plugin downloads). Moving a whole directory means everything the app writes later lands in the repo. A whole directory is fine when it holds only hand-written config.
- **Does the app keep the link?** Some apps save by renaming a new file over the old one, which replaces a link to a single file with a regular file (gitk and git-cola do this). Linking the whole directory avoids it, if nothing else the app writes there should stay out of the repo. KDE apps keep links: KConfig saves through Qt's `QSaveFile`, which follows the link first. If unsure, have the user change a setting in the app after stowing and check with `ls -l` that the file is still a link.
- **Machine-written files** (KDE `*rc` files, app state with window geometry or recent items) work, but every change in the app shows up as a diff. Tell the user before adopting them. KDE `*ui.rc` files in `~/.local/share/kxmlgui5` also change when the app updates: KDE merges the user's shortcuts and toolbars into the new built-in layout. Those diffs should be committed.
- **Flatpak apps** see a link into the repo only if their sandbox can access that path: `flatpak info --show-permissions <app-id>`.

## 2. Move the files and link them back

`dotfiles-adopt <package> <path...>` (in `shell/.shell-utils/functions-setup.sh`) moves the files into the package and runs stow. Paths must be under `$HOME`; inside a linked directory such as `~/Projects`, pass the full `~/...` path.

If the files are not in this session's `$HOME` (for example the session runs in a container), give the user the command to run instead.

## 3. Register the package in setup

In `stow_dotfiles` in `setup/aux/restore-configs.sh`:

- Add a new package to the `packages=( ... )` list, keeping it sorted.
- On a fresh machine stow links the highest directory on the package path that does not exist yet: a package with `.local/share/kxmlgui5/dolphin/dolphinui.rc` would link all of `~/.local` if it is missing. For each parent directory of the adopted files, check whether other programs keep files there (for example `~/.local/share/kxmlgui5`, or `~/.config/<app>` when only some of its files are stowed), and add the deepest such directory to the `mkdir -p` line unless it is already there. The test script lists the result under "real directories".

## 4. Remove the files from konsave

Delete each moved file from `konsave/.config/konsave/conf.yaml`. Setup applies the konsave profile after stowing, on top of the links. Keep entries for other paths, such as a directory with a similar name under `~/.config`. Check the file still parses:

```bash
python3 -c "import yaml; yaml.safe_load(open('konsave/.config/konsave/conf.yaml'))"
```

## 5. Test

```bash
bash -n setup/aux/restore-configs.sh
.claude/skills/add-stow-package/scripts/test-stow-dotfiles.sh <path-in-home>...
```

The script runs `stow_dotfiles` twice in a throwaway home. Pass the moved paths (relative to `$HOME`, e.g. `.gitconfig`) to create them there as plain files first. Expect both runs to succeed, each passed file to become a link with a `.bak` next to it, and every directory from the `mkdir -p` line to stay a real directory.

## 6. CLAUDE.md

Add an entry to the Layout section only if the package comes with a rule a reader must follow, like `claude/` and `konsave/` there. Ordinary packages are not listed.

## 7. Stage and commit

Stage only what this skill changed, as described under "Git staging and commits" in `~/.claude/CLAUDE.md`. `setup/aux/restore-configs.sh` usually also holds the user's own hunks, so it needs the partial staging described there. Before committing, check that the staged script still parses: `git show :setup/aux/restore-configs.sh | bash -n`. If something was already staged before this skill ran, stop and ask instead of committing it along.

Commit with a subject line only, no body:

```bash
git commit -m "<package>: add stow package for <files>"
```

If git has no identity in this environment, use the latest commit's author for this commit only:
`git -c user.name="$(git log -1 --format=%an)" -c user.email="$(git log -1 --format=%ae)" commit -m "..."`.

The gitleaks pre-commit hook runs on commit; if it reports a leak, unstage the file and tell the user. Do not push.

## 8. Report

Say what changed, how it was tested and the commit hash. If the index holds a partial version of a file, say so: the user's own lines stay unstaged in the working tree.
