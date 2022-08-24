#!/bin/bash

VERSION=1.0.0
TEMP1="/tmp/delete-unused-assets-1.txt"
TEMP2="/tmp/delete-unused-assets-2.txt"
IFS='
'

rm $TEMP1
rm $TEMP2

cecho () {

    if [ "$2" == "info" ] ; then
        COLOR="96m";
    elif [ "$2" == "strong" ] ; then
        COLOR="94m";
    elif [ "$2" == "success" ] ; then
        COLOR="92m";
    elif [ "$2" == "warning" ] ; then
        COLOR="93m";
    elif [ "$2" == "error" ] ; then
        COLOR="91m";
    else #default color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR" "$1";
}

pressAnyKey() {
	read -n 1 -s -r -p "Press any key to continue"
	echo " "
}


cecho "CrafterCMS Delete Unused Assets from Project v$VERSION\n" "strong"

cecho "Collecting unused assets, press any key to review the files to be deleted.\n" "info"
pressAnyKey
find static-assets -type f >> $TEMP1
for i in $( cat $TEMP1 ); do
	if ! grep -Ir $i . > /dev/null; then
		echo $i >> $TEMP2
		echo Found unused asset: $i
	fi
done

#cecho Plea
less $TEMP2

rm $TEMP1
rm $TEMP2
