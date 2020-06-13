#/bin/bash

source .params.txt


printf "Extracting $rarfile\n"

unrar e $rarfile $rardir; vstat=$?

case $vstat in
    0) printf "moving files to $olddir\n"; mv $oldfiles $olddir;;
    1) printf '%s\n' "Oups something went wrong\nCommand exited with non-zero"; exit 1;;
    *) printf 'ignoring exit statusi: $vstat'; exit 1;;
esac
