#!/bin/bash

read -rep $'What pattern do you want to search ?\n' pattern
read -rep $'What is the new pattern ?\n' newpattern


files=$(grep -rli $pattern)

for i in $files
	do sed -i s/$pattern/$newpattern/gi $i
done
