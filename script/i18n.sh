#!/usr/bin/env bash

set -e

BashDir=$(cd "$(dirname $BASH_SOURCE)" && pwd)
if [[ "$Command" == "" ]];then
    Command="$0"
fi

function help(){
    echo "i18n helper"
    echo
    echo "Usage:"
    echo "  $Command [flags]"
    echo
    echo "Flags:"
    echo "  -a, --arb         build for arb"
    echo "  -d, --dart        build for dart"
}
ARGS=`getopt -o had --long arb,dart -n "$Command" -- "$@"`
eval set -- "${ARGS}"
arb=0
dart=0
clear=0
while true
do
    case "$1" in
        -h|--help)
            help
            exit 0
        ;;
        -a|--arb)
            arb=1
            shift
        ;;
        -d|--dart)
            dart=1
            shift
        ;;
        --)
            shift
            break
        ;;
        *)
            echo Error: unknown flag "$1" for "$Command"
            echo "Run '$Command --help' for usage."
            exit 1
        ;;
    esac
done

if [[ "$arb" == 1 ]];then
    cd "$BashDir/i18n"
    if [[ -d lib/i18n ]];then
        rm lib/i18n -rf
    fi
    cp ../../lib/i18n ./lib/i18n -r
    echo flutter-i18n arb
    ../flutter-i18n arb
    cp ./lib/i18n/*.arb ../../lib/i18n/
    exit 0
fi

if [[ "$dart" == 1 ]];then
    cd "$BashDir/i18n"
    if [[ -d lib ]];then
        if [[ -d lib/i18n ]];then
            rm lib/i18n -rf
        fi
    else
        mkdir lib
    fi
    cp ../../lib/i18n ./lib/i18n -r
    if [[ -f ./lib/i18n/messages_all.dart ]];then
        cp ./lib/i18n/messages_all.dart ./lib/i18n/messages_all.dart.fix
    fi

    echo flutter-i18n dart
    ../flutter-i18n dart
    if [[ -f ./lib/i18n/messages_all.dart.fix ]];then
        mv ./lib/i18n/messages_all.dart.fix ./lib/i18n/messages_all.dart
    fi
    cp ./lib/i18n/*.dart ../../lib/i18n/
    rm lib/i18n -rf
    exit 0
fi

help
exit 1