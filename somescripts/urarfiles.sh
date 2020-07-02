#/bin/bash

source .params.txt


for f in $rarfile
    do
      printf "Extracting $f\n"
      filename=$(echo $f | sed "s/.part1.rar//g")

      unrar e $f $rardir; vstat=$?

      case $vstat in
          0) printf "moving files to $olddir\n"; mv $filename* $olddir ;;
          1) printf '%s\n' "Oups something went wrong\nCommand exited with non-zero"; exit 1;;
          *) printf 'ignoring exit statusi: $vstat'; exit 1;;
      esac
    done
