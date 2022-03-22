#!/usr/bin/env bash

function checkForRootUserGuard ()
{
    if [[ "$USER" == "root" ]]; then
        echo "Do not run this script as superuser"
        echo "Try run without sudo or swithch to regular user"
        exit 1
    fi
}

function yesOrNo 
{
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

function printHead ()
{
    TEXT="$1"
    echo "============== ${TEXT} =============="
    echo ""
}

function cleanUpFs ()
{
    rm -rf "temp"
}

function prepareFs ()
{
    cleanUpFs
    mkdir temp
    echo ls
}

function copyHookFile ()
{
    local HOOK_FILE="$1"
    cp "hooks/${HOOK_FILE}" "temp/"
}

function preparePackageListBackupHook ()
{
    local HOOK_PATH="$1"
    copyHookFile "${HOOK_PATH}"
    sed "s|%USER%|${TYPED_USER}|g" -i "temp/${HOOK_PATH}"
    sed "s|%BACKUP_PATH%|${BACKUP_PATH}|g" -i "temp/${HOOK_PATH}"
}

function promptPackageListBackupData ()
{
    read -p "Type your username to store packages backup: " -r TYPED_USER
    read -p "Type a path in user home directory where package list will be stored: " -r BACKUP_PATH
}

function run ()
{
    # sudo cp temp/*.hook /etc/pacman.d/hooks/

    echo "cp temp/*.hook /etc/pacman.d/hooks/"
    cp ./temp/package-list-export.hook .
    cat ./package-list-export.hook
}

function main ()
{
    checkForRootUserGuard
    prepareFs

    printHead "Setup package list backup"
    promptPackageListBackupData
    preparePackageListBackupHook package-list-export.hook

    echo "All hooks in the 'hooks' directory will be copied to /etc/pacman.d/hooks/ with the superuser rights"
    sleep 2
    yesOrNo "Are your sure? Files will be copied to the system directory" && echo "" && echo "Well. You know what you do :)" && run

    cleanUpFs
}

main

