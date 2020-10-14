#!/bin/bash

export IFS="@"
sentence="20150924@20150925@20150928"
for word in $sentence; do
  echo "$word"
	/home/julien/SVN/scripts/julien/star_auto_transfert.sh ${word}
done
