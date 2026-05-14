#!/bin/bash

PROJECT_PATH=$1
CURRENT_BRANCH=$(git -C $PROJECT_PATH branch --show-current)
UPSTREAM_BRANCH=$(git -C $PROJECT_PATH branch -vv | grep $CURRENT_BRANCH | awk '{ print $4 }' | tr -d '[:')
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--current)
            git-dag -r $PROJECT_PATH $CURRENT_BRANCH
            exit 0
            ;;
        -u|--upstream-diff)
            git-dag -r $PROJECT_PATH $CURRENT_BRANCH..$UPSTREAM_BRANCH
            exit 0
            ;;
        -r|--review)
            REVIEW_BRANCH="origin/$2"
            git-dag -r $PROJECT_PATH $UPSTREAM_BRANCH..$REVIEW_BRANCH &
            exit 0
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done
