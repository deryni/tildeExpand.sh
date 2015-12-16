#!/bin/bash

tildecase() {
    case $path in
        "~"|"~"/*)
            path=${HOME-~}${path:1}
            ;;
        "~"[0-9]*|"~"[+-][0-9]*)
            local num=${path:1}
            if [[ $num -eq $num ]] 2>/dev/null; then
                if [ "${num:0:1}" = "-" ]; then
                    ((num-=1))
                fi
                local opath=$path
                path=${DIRSTACK[@]:$num:1}
                # Handle the "special" case of ${DIRSTACK[0]} using unexpanded ~.
                if [ "${path:0:1}" = "~" ]; then
                    tildecase
                fi
                : "${path:=$opath}"
            fi
            ;;
        "~+"*)
            path=$PWD${path:2}
            ;;
        "~-"*)
            path=${OLDPWD:-${path:0:2}}${path:2}
            ;;
        "~"*)
            local username=${path%%/*}
            IFS=: read -r _ _ _ _ _ homedir _ < <(getent passwd "${username:1}")
            path=${homedir:-${path%%/*}}${path#$username}
            ;;
    esac
}

doExpand() {
    local path
    local -a resultPathElements

    for path in "$@"; do
        tildecase "$path"
        resultPathElements+=( "$path" )
    done
    local result
    printf -v result '%s:' "${resultPathElements[@]}"
    printf '%s\n' "${result%:}"
}

expandAssign() {
    local -a pathElements
    IFS=: read -r -a pathElements <<<"$1"
    : "${pathElements[@]}"
    doExpand "${pathElements[@]}"
}

expandString() {
    doExpand "$1"
}
