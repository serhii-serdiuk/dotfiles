git-log() {
    if [ -z $1 ]; then
        git log --oneline
        return
    fi

    if [[ "$1" =~ ^-?[0-9]+$ ]]; then          # First argument is number
        if [ "$1" -gt 0 ]; then
            local commits_number=$((-1 * $1))  # Multiply by -1 if the number is positive
        else
            local commits_number=$1            # Use number as is if it's negative
        fi
        git log --oneline $commits_number
    else
        git log --oneline "$1"
    fi
}

git-log-file() {
    local file_path=$1
    local oneline_option=--oneline
    if [[ $# -eq 2 ]] && [[ $2 == "-v" ]]; then
        oneline_option=
    fi
    git log --summary --find-renames=40% $oneline_option --follow $file_path
}

git-switch() {
    GIT_RETURN_BRANCH=$(git branch --show-current)
    git stash
    git switch $1
    git stash pop
}

git-switch-back() {
    git switch $GIT_RETURN_BRANCH
}

git-switch-new() {
    GIT_RETURN_BRANCH=$(git branch --show-current)
    local new_branch=$1
    local remote_branch=$1

    if [ ! -z $2 ]; then
        remote_branch=$2
    fi

    git switch --create $new_branch --track origin/$remote_branch &&
    git branch -vv
}

git-checkout-upstream() {
    GIT_RETURN_BRANCH=$(git branch --show-current)
    local upstream_branch=$(git rev-parse --abbrev-ref $GIT_RETURN_BRANCH@{upstream})
    git checkout $upstream_branch
}

git-checkout-files() {
    local src=$1
    local files=${@:2}
    git checkout $src -- $files
}

git-diff-branches() {
    local first_branch=$(git branch --show-current)
    local second_branch=$(git rev-parse --abbrev-ref $first_branch@{upstream})

    if [ $# -eq 1 ]; then
        second_branch=$1
    fi
    if [ $# -eq 2 ]; then
        first_branch=$1
        second_branch=$2
    fi

    local output=$(git log --oneline --graph --decorate --abbrev-commit $first_branch..$second_branch)
    if [ ! -z "$output" ]; then
        echo "Diff for $first_branch..$second_branch:"
        git log --oneline --graph --decorate --abbrev-commit $first_branch..$second_branch
    fi

    output=$(git log --oneline --graph --decorate --abbrev-commit $second_branch..$first_branch)
    if [ ! -z "$output" ]; then
        echo
        echo "Diff for $second_branch..$first_branch:"
        git log --oneline --graph --decorate --abbrev-commit $second_branch..$first_branch
    fi
}

git-pull() {
    echo "Fetching..."
    local output=$(git fetch)
    if [ ! -z "$output" ]; then
        echo $output
        git branch -vv
    fi

    output=$(git-diff-branches)
    if [ -z "$output" ]; then
        echo "Branch is already up to date."
    else
        echo
        git-diff-branches
        echo
        echo "Updating branch..."
        git pull
        git branch -vv
    fi
}

# Private function for usage inside this script
_git_diff_upstream() {
    local local_branch=$(git branch --show-current)
    local upstream_branch=$(git rev-parse --abbrev-ref $first_branch@{upstream})
    echo "Diff with $upstream_branch:"
    git log --oneline --graph --decorate --abbrev-commit $upstream_branch..$local_branch
}

git-update-branch() {
    GIT_RETURN_BRANCH=$(git branch --show-current)
    local dest_branch=$1
    local rebase_branch=$2

    git commit --all --message="Temporary commit before branch update" > /dev/null &&
    git switch $dest_branch &&
    git pull

    if [ ! -z $rebase_branch ]; then
        # NOTE: this is possibility to pull changes from branch other than tracking
        git pull origin $rebase_branch &&
        _git_diff_upstream
    else
        git-switch-back &&
        git branch -vv
    fi
}

# git-update-multiple-branches() {
#     local bold="\e[1m"
#     local no_format="\e[0m"
#
#     for branch in $@; do
#         echo -e "${bold}Updating $branch branch...${no_format}"
#         git-update-branch $branch
#     done
#
#     git branch -vv
# }

git-duplicate-branch() {
    local src_branch=$(git branch --show-current)
    local dest_branch=$src_branch-copy

    if [ $# -eq 1 ]; then
        dest_branch=$1
    fi
    if [ $# -eq 2 ]; then
        src_branch=$1
        dest_branch=$2
    fi

    git branch --copy $src_branch $dest_branch && git branch -vv
}

git-rename-branch() {
    local src_branch=$(git branch --show-current)
    local dest_branch=$1

    if [ $# -eq 1 ]; then
        dest_branch=$1
    fi
    if [ $# -eq 2 ]; then
        src_branch=$1
        dest_branch=$2
    fi

    git branch --move $src_branch $dest_branch && git branch -vv
}

git-remove-branches() {
    git branch -D $@ && git branch -vv
}

git-reset-hard() {
    local commits_number=0

    if [ ! -z $1 ]; then
        commits_number=$1
    fi

    git reset --hard HEAD~$commits_number
    _git_diff_upstream
}

git-reset-soft() {
    local commits_number=0

    if [ ! -z $1 ]; then
        commits_number=$1
    fi

    git reset --soft HEAD~$commits_number
    _git_diff_upstream
}

git-commit-fixup() {
    local commit=HEAD

    if [ ! -z $1 ]; then
        commit=$1
    fi

    git commit --fixup=$commit
    _git_diff_upstream
}

git-commit-squash() {
    local commit=HEAD

    if [ ! -z $1 ]; then
        commit=$1
    fi

    git commit --squash=$commit
    _git_diff_upstream
}

git-commit-temporary() {
    git commit --all --message="Temporary commit"
    _git_diff_upstream
}

git-rebase-interactive() {
    git rebase -i $1 &&
    _git_diff_upstream
}

git-copy-commit() {
    GIT_RETURN_BRANCH=$(git branch --show-current)
    local dest_branch=$GIT_RETURN_BRANCH
    local commit=$1

    if [ $# -eq 2 ]; then
        dest_branch=$1
        commit=$2
    fi

    git switch $dest_branch &&
    git cherry-pick $commit &&
    _git_diff_upstream &&
    git-switch-back &&
    git branch -vv
}

git-replace-branch-head() {
    GIT_RETURN_BRANCH=$(git branch --show-current)
    local dest_branch=$1
    local commit=$2

    git switch $dest_branch &&
    git reset --hard HEAD~1 &&
    git cherry-pick $commit &&
    _git_diff_upstream &&
    git-switch-back
}
