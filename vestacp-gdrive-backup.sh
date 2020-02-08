#!/bin/bash
SHELL=/bin/bash PATH=/bin:/sbin:/usr/bin:/usr/sbin
function vestacp_gdrive_backup() {
    A=$1
    mincount=$2
    varlen=${#A}

    cd /
    if [ ! -d "vestacp-gdrive-backups" ]; then
        mkdir "vestacp-gdrive-backups"
    fi
    if [ ! -d "vestacp-empty-dir" ]; then
        mkdir "vestacp-empty-dir"
    fi
    if [ ! -f "/vestacp-empty-dir/emptyfile.txt" ]; then
        touch "/vestacp-empty-dir/emptyfile.txt"
    fi

    cd /vestacp-gdrive-backups
    if [ ! -d "$A" ]; then
        mkdir "$A"
    fi

    cd /backup
    for file in *.tar
    do
        if [[ ${file:0:$varlen} = "$A" ]]; then
            mv "$file" "/vestacp-gdrive-backups/$A"
        fi
    done

    cd /vestacp-gdrive-backups
    if [ -d "$A" ]; then
        files=$(find "$A" -type f | wc -l)
        if ((${files} > ${mincount})); then
            cd "$A"
            rm "$(ls -t | tail -1)"
        fi
    fi
}

# Example
# user = name of user in VestaCP
# 2 = maximum number of backup files allowed
vestacp_gdrive_backup user 2