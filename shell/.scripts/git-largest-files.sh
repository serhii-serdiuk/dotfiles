#!/bin/bash

# Check if pack index files exist
pack_files=$(ls .git/objects/pack/*.idx 2>/dev/null)
if [ -z "$pack_files" ]; then
    echo "No pack files found. Run 'git gc' to generate pack files."
    exit 1
fi

# For each of the largest blobs, find the related commit that modified it
join -o "1.1 1.2 2.3" \
    <(git rev-list --objects --all | sort) \
    <(git verify-pack -v .git/objects/pack/*.idx | sort -k3 -n | tail -5 | sort) | \
sort -k3 -nr | \
while read -r blob_hash file size_bytes; do
    # Get commit info for this blob
    commit_info=$(git log --all --find-object=$blob_hash --pretty=format:"%H %ci" -1)
    commit_hash=$(echo "$commit_info" | cut -d' ' -f1)
    commit_date=$(echo "$commit_info" | cut -d' ' -f2-)

    size=$(awk '{ printf "%.2fMB", $1/1024/1024 }' <<< "$size_bytes")
    echo "$commit_hash $file $size $commit_date"
done
