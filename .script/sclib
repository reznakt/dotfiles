#!/usr/bin/env bash

function sclog() {
    echo "$(basename $0): $1: $2"
}

function scinfo() {
    sclog "info" "$1"
}

function scwarn() {
    sclog "warning" "$1"
}

function scerr() {
    sclog "error" "$1"
}

function scfatal() {
    scerr "$1"
    exit 1
}

function isset() {
     test -n "$1"
     return $?
}

function isunset() {
    test -z "$1"
    return $?
}

function scset() {
    if isunset "$1"; then
        scerr "expected at least 1 argument"
        return 1
    fi

    printf -v "$1" "%s" "true"
    return $?
}

function scunset() {
    if isunset "$1"; then
        scerr "expected at least 1 argument"
        return 1
    fi

    eval "unset $1"
    return $?
}

