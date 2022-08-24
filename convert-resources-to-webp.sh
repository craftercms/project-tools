#!/bin/bash

VERSION=1.0.0
IMAGE_TYPES=( "jpg" "jpeg" "png" "gif" )
TARGET_TYPE="webp"
TEMP="/tmp/convert-project-resources.txt"
IFS='
'

rm $TEMP

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


cecho "CrafterCMS Convert Project to WebP version v$VERSION\n" "strong"

cecho "Collecting resources, press any key to review the files to be converted.\n" "info"
pressAnyKey
for i in "${IMAGE_TYPES[@]}"; do
	for j in `find . -name "*.$i"`; do
		echo $j \-\> ${j%.*}.$TARGET_TYPE >> $TEMP
	done
done
less $TEMP
read -p "Convert the files? (yes/no) " REPLY
if [ "$REPLY" != "yes" ] && [ "$REPLY" != "y" ]; then
    cecho "Canceling conversion\n" "strong"
    exit 0
fi

for i in "${IMAGE_TYPES[@]}"; do
	for j in `find . -name "*.$i"`; do
		cwebp "$j" -o "${j%.*}.$TARGET_TYPE"
		rm "$j"
	done
done

cecho "Now that resources have been converted, we will update all references to these resources in XML, CSS, SCSS, and FTL files.\n" "info"
pressAnyKey
for i in "${IMAGE_TYPES[@]}"; do
	find . -type f -name '*.css'| xargs perl -pi -e "s/(static-assets\/.*).$i/\1\.$TARGET_TYPE/g;" 2>/dev/null
	find . -type f -name '*.scss'| xargs perl -pi -e "s/(static-assets\/.*).$i/\1\.$TARGET_TYPE/g;" 2>/dev/null
	find . -type f -name '*.xml'| xargs perl -pi -e "s/(static-assets\/.*).$i/\1\.$TARGET_TYPE/g;" 2>/dev/null
	find . -type f -name '*.ftl'| xargs perl -pi -e "s/(static-assets\/.*).$i/\1\.$TARGET_TYPE/g;" 2>/dev/null
done

cecho "Next we will update the project policy to disallow PNG, JPG, and Gif files from being uploaded.\n" "info"
pressAnyKey
perl -pi -e "s/<\/site-policy>/   <statement>
      <target-path-pattern>\/.*<\/target-path-pattern>
      <permitted>
         <mime-types>*\/*<\/mime-types>
      <\/permitted>
      <denied>
         <mime-types>image\/svg+xml<\/mime-types>
      <\/denied>
   <\/statement>
<\/site-policy>/g" ./config/studio/site-policy-config.xml

cecho "Site conversion complete. Please use " "info"
cecho "git diff " "strong"
cecho "to validate the changes and commit if happy with the updates\n" "info"
cecho "To revert all changes, run " "info"
cecho "git reset && git clean -f\n" "strong"
cecho "Done\n" "info"

rm $TEMP
