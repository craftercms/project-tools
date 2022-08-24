#!/bin/bash

VERSION=1.0.0
TEMP1="/tmp/delete-unused-assets-1.txt" 2> /dev/null
TEMP2="/tmp/delete-unused-assets-2.txt" 2> /dev/null
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
	echo "Processing..."
}


cecho "CrafterCMS Delete Unused Assets from Project v$VERSION\n" "strong"

cecho "Collecting unused assets, press any key to review the files to be deleted.\n" "info"
pressAnyKey
find static-assets -type f >> $TEMP1
for i in $( cat $TEMP1 ); do
	if ! grep -Ir $i . > /dev/null; then
		if ! [[ $i == *keep ]]; then
			echo $i >> $TEMP2
			echo Found unused asset: $i
		fi
	fi
done

cecho "Please review the assets to be removed\n" "info"
pressAnyKey
less $TEMP2

read -p "Remove these assets? (yes/no) " REPLY
if [ "$REPLY" != "yes" ] && [ "$REPLY" != "y" ]; then
    cecho "Canceling asset deletion\n" "strong"
    exit 0
fi

for i in $( cat $TEMP2 ); do
	read -p "delete the asset '$i'? (yes/no) " REPLY
	if [ "$REPLY" != "yes" ] && [ "$REPLY" != "y" ]; then
		rm $i
	fi
done

rm $TEMP1 2> /dev/null
rm $TEMP2 2> /dev/null
