#!/bin/bash

if [ "$1" = "-v" ]; then
    v=$1
    shift
fi

. tildeExpand.sh

strexp() {
    local v=$(printf %q "$1")
    eval echo "${v/#\\~/"~"}"
}

t() {
    exp=$(expandPath "$1")
    if [ "$v" ]; then
        printf \\n >&2
        printf 'Original: %s\n' "$1" >&2
        printf 'Expanded: %s\n' "$exp" >&2
        printf 'Expected: %s\n' "$2" >&2
    fi
    if [ "$2" = "$exp" ]; then
        printf 'Succeeded: '\''%s'\''\n' "$1"
    else
        printf 'Failed: '\''%s'\''\n' "$1"
    fi
}

cd /tmp; cd -

name1="~/Documents/over  enthusiastic"
name2="~crl/Documents/double  spaced"
name3="/work/whiffle/two  spaces  are  better  than one"
name4="~testuser/Documents/double  spaced"

t "$name1" "$(strexp "$name1")"
t "$name2" "$(strexp "$name2")"
t "$name3" "$(strexp "$name3")"
t "$name4" "$(strexp "$name4")"
t "~"          "$HOME"
t "~/"         "$HOME/"
t "~crl"       ~crl
t "~crl/"      ~crl/
t "~testuser"  ~testuser
t "~testuser/" ~testuser/
t "~+"         ~+
t "~+/plus"    ~+/plus
t "~-"         ~-
t "~-/minus"   ~-/minus

o=$PWD
pushd / >/dev/null
pushd /tmp >/dev/null
pushd /opt >/dev/null
pushd /var >/dev/null
pushd "$o" >/dev/null

t  '~1'  ~1
t '~+1' ~+1
t '~-1' ~-1
t  '~2'  ~2
t '~+2' ~+2
t '~-2' ~-2
t  '~8'  ~8
t '~+8' ~+8
t '~-8' ~-8
