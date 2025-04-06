#! /bin/bash
#use this if you used the old and broken sort.sh
files="$(find . -type f ! -name "*.*")"
#https://superuser.com/a/284226
while IFS= read -r line || [[ -n $line ]]; do
    echo mv \'"$line"\' \'"${line##*/}.flac"\'
    mv "$line" "${line##*/}.flac"
done < <(printf '%s' "$files")
