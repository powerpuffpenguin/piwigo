#!/usr/bin/env bash

set -e

BashDir=$(cd "$(dirname $BASH_SOURCE)" && pwd)
if [[ "$Command" == "" ]];then
    Command="$0"
fi

function help(){
    echo "flutter helper script"
    echo
    echo "Usage:"
    echo "  $0 [flags]"
    echo "  $0 [command]"
    echo
    echo "Available Commands:"
    echo "  help              help for $0"
    echo "  run               run project"
    echo "  i18n              build i18n"
    echo "  a/android         build for android"
    echo "  clear             clear output"

    echo
    echo "Flags:"
    echo "  -h, --help          help for $0"
}

case "$1" in
    help|-h|--help)
        help
    ;;
    clear)
        shift
        export Command="$0 run"
        cd "$BashDir"
        flutter clean
    ;;
    run)
        shift
        export Command="$0 run"
        cd "$BashDir"
        flutter run
    ;;
    i18n)
        shift
        export Command="$0 i18n"
        "$BashDir/script/i18n.sh" "$@"
    ;;
    a|android)
        shift
        export Command="$0 android"
        "$BashDir/script/android.sh" "$@"
    ;;
    *)
        if [[ "$1" == "" ]];then
            help
        elif [[ "$1" == -* ]];then
            echo Error: unknown flag "$1" for "$0"
            echo "Run '$0 --help' for usage."
        else
            echo Error: unknown command "$1" for "$0"
            echo "Run '$0 --help' for usage."
        fi        
        exit 1
    ;;
esac
