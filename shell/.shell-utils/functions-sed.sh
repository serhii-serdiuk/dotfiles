replace-substring() {
    local first=$1
    local second=$2
#     sed -En "s/$first/$second/p"  # NOTE: doesn't work for lspkgv to replace "--" with ""
    sed -E "s/$first/$second/"
}

replace-substring-file() {
    local first=$1
    local second=$2
    local file=$3
    sed -Ei "s/$first/$second/g" $file
}

delete-line() {
    local substring=$1
    sed "/$substring/d"  # NOTE: -E option doesn't work in case of scan-network function
#     sed -E "/$substring/d"  # NOTE: need to investigate for which cases this option necessary
}

delete-lines-file() {
    local substring=$1
    local file=$2
    sed -Ei "/$substring/d" $file
}

append-line-after() {
    local match=$1
    local line=$2
    local file=$3
    sed -Ei "/$match/a $line" $file
}

insert-line-before() {
    local match=$1
    local line=$2
    local file=$3
    sed -Ei "/$match/i $line" $file
}

comment-script-line() {
    local substring=$1
    local file=$2
    sed -Ei "/$substring/s/^/#/g" $file
}

uncomment-script-line() {
    local substring=$1
    local file=$2
    sed -Ei "/$substring/s/^#//g" $file
}
