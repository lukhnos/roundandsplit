#!/bin/bash
FIRA_DEST=$PWD/Common/FiraFonts
FIRA_ZIP=FiraFonts3111.zip
FIRA_URL=http://www.carrois.com/wordpress/downloads/fira_3_1/$FIRA_ZIP

echo Installing Fira fonts
mkdir -p "$FIRA_DEST"
pushd "$FIRA_DEST" > /dev/null

FIRA_TMP=$PWD/temp-$RANDOM

if [ ! -e "$FIRA_ZIP" ]
then
	echo Obtaining $FIRA_URL
	curl -O "$FIRA_URL" 
fi
echo Unzipping the archive
unzip -nq "$FIRA_ZIP" -d "$FIRA_TMP"

echo Using only the .otf files
mv `find "$FIRA_TMP" -name "*.otf"` "$FIRA_DEST/"

echo Removing the temp dir: $FIRA_TMP
rm -rf "$FIRA_TMP"

popd > /dev/null
