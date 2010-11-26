#﻿!/bin/bash
# Converts all symbolic links in a directory to hard links. 
# See http://ubuntuforums.org/showthread.php?t=1508728 
#   for any updates/problems.
#
# This script is based on the above forum post 
#   by ks07 (http://ubuntuforums.org/member.php?u=675056)

if [ -d $1 ]; then
    read -n 1 -t 30 \
      -p "About to convert all symlinks in '$1'; continue? [y/N]" \
      confirm
    echo
    if [ -z "$confirm" ]; then
        echo "Exiting. No changes made."
        exit
    fi
    if [ "$confirm" == y ]; then
        cd "$1" &&
        FOLDER="*"
        for file in $FOLDER
        do
            if [ -L "$file" ]; then
                target=$(readlink "$file")
                echo "Converting link to $file"
                mv "$file" "$file.old" &&
                ln "$target" "$file" &&
                rm "$file.old"
            else
                echo "$file not a symlink, skipping"
            fi
        done
    else
        echo "Exiting. No changes made."
    fi

else
    echo "$1 is not a directory, exiting."
fi
exit
