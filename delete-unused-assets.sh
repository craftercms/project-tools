#!/bin/bash

VERSION=1.0.0
TEMP1="/tmp/delete-unused-assets-1.txt"
TEMP2="/tmp/delete-unused-assets-2.txt"
IFS='
'

rm $TEMP1 > /dev/null 2>&1
rm $TEMP2 > /dev/null 2>&1

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
			cecho "Found unused asset: " "info"
			cecho "$i\n" "strong"
		fi
	fi
done

cecho "Please review the assets to be removed\n" "info"
pressAnyKey
less $TEMP2

read -p "Continue to asset removal? (yes/no) " REPLY
if [ "$REPLY" != "yes" ] && [ "$REPLY" != "y" ]; then
    cecho "Canceling asset deletion\n" "strong"
    exit 0
fi

for i in $( cat $TEMP2 ); do
	#read -p "delete the asset '$i'? (yes/no) " REPLY
	#if [ "$REPLY" = "yes" ] || [ "$REPLY" = "y" ]; then
		cecho "Removing file '$i'\n" "strong"
		rm $i
	#fi
done

rm $TEMP1 > /dev/null 2>&1
rm $TEMP2 > /dev/null 2>&1

cecho "Asset deletion complete. Please use " "info"
cecho "git status " "strong"
cecho "to validate the changes and commit if happy with the updates\n" "info"
cecho "To revert all changes, run " "info"
cecho "git reset && git clean -f\n" "strong"
cecho "Done\n" "info"

