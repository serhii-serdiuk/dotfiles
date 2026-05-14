# User specific aliases and functions
if [ -d ~/.shell-utils ]; then
    for file in ~/.shell-utils/*; do
        if [ -f "$file" ]; then
            . "$file"
        fi
    done
fi
