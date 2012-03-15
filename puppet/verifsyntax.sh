#!/bin/bash
# -*- coding: UTF8 -*-

while getopts :c:a option;
do
	case "$option" in
		"c") puppet --parseonly $OPTARG
		;;
		"a") find -name '*.pp' | xargs -n 1 -t puppet --parseonly
		;;
                 *) echo "argument invalide essayez -c -a ";;
	       esac
done

