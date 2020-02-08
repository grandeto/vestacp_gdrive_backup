#!/bin/bash
SHELL=/bin/bash PATH=/bin:/sbin:/usr/bin:/usr/sbin
function vesta_gdrive_backup() {
    A=$1
    mincount=$2
    varlen=${#A}

    cd /
    if [ ! -d "vesta-gdrive-backups" ]; then
        mkdir "vesta-gdrive-backups"
    fi
    if [ ! -d "vesta-empty-dir" ]; then
        mkdir "vesta-empty-dir"
    fi
    if [ ! -f "/vesta-empty-dir/emptyfile.txt" ]; then
        touch "/vesta-empty-dir/emptyfile.txt"
    fi

    cd /vesta-gdrive-backups
    if [ ! -d "$A" ]; then
        mkdir "$A"
    fi

    cd /backup
    for file in *.tar
    do
        if [[ ${file:0:$varlen} = "$A" ]]; then
            mv "$file" "/vesta-gdrive-backups/$A"
        fi
    done

    cd /vesta-gdrive-backups
    if [ -d "$A" ]; then
        files=$(find "$A" -type f | wc -l)
        if ((${files} > ${mincount})); then
            cd "$A"
            rm "$(ls -t | tail -1)"
        fi
    fi
}

# Example
# vesta-user = name of user from VestaCP dashboard
# 2 = maximum number of backup files allowed
vesta-gdrive-backup vesta-user 2