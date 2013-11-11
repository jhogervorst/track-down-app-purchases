#!/bin/bash

# Track Down App Purchases v0.1
# Shell script to get a list of all iOS apps in your iTunes Library,
# showing which Apple ID was used to purchase each app.
#
# Copyright © 2013 Jonathan Hogervorst. All rights reserved.
# This code is licensed under MIT license. See LICENSE for details.

# Source: http://stackoverflow.com/a/6885918/251760
function format_width
{
	local WIDTH=$1
	local STR=$2
	local BYTE_WIDTH=$( echo -n "$STR" | wc -c )
	local CHAR_WIDTH=$( echo -n "$STR" | wc -m )
	echo $(( $WIDTH + $BYTE_WIDTH - $CHAR_WIDTH ))
}

function print_cell
{
	local WIDTH=$1
	local STR=$2
	local FORMAT_WIDTH=$( format_width "$WIDTH" "$STR" )
	printf "%-*.*s" "$FORMAT_WIDTH" "$FORMAT_WIDTH" "$STR"
}

function print_row
{
	print_cell 30 $1
	printf " | "
	print_cell 14 $2
	printf " | "
	print_cell 30 $3
	printf "\n"
}

function extract_key
{
	local KEY=$1
	local METADATA=$2
	echo "$METADATA" | sed -e "/<key>$KEY<\\/key>/I,/<string>/I!d" | sed -En "s/^.*<string>(.+)<\\/string>.*$/\\1/Ip"
}

echo ""
LIBRARY_PATH_DEFAULT="~/Music/iTunes"
read -p "Path to iTunes Library [$LIBRARY_PATH_DEFAULT]: " LIBRARY_PATH
LIBRARY_PATH="${LIBRARY_PATH:-$LIBRARY_PATH_DEFAULT}"
LIBRARY_PATH="${LIBRARY_PATH/\~/$HOME}"
LIBRARY_PATH="${LIBRARY_PATH%/}"

APP_FILES=$( find "$LIBRARY_PATH/iTunes Media/Mobile Applications" -type f -name "*.ipa" )
INVALID_APP_FILES=""

OIFS="$IFS"
IFS=$'\n'

echo ""
DASHES="------------------------------"
print_row "$DASHES" "$DASHES" "$DASHES"
print_row "App Name" "Bundle Name" "Apple ID"
print_row "$DASHES" "$DASHES" "$DASHES"

for APP_FILE in $APP_FILES
do
	APP_FILE_METADATA=$( unzip -p "$APP_FILE" iTunesMetadata.plist 2> /dev/null | plutil -convert xml1 -o - - )
	APP_FILE_APPLE_ID=$( extract_key "appleId" "$APP_FILE_METADATA" )
	APP_FILE_BUNDLE_DISPLAY_NAME=$( extract_key "bundleDisplayName" "$APP_FILE_METADATA" )
	APP_FILE_ITEM_NAME=$( extract_key "itemName" "$APP_FILE_METADATA" )
	
	if [ ! -z "$APP_FILE_APPLE_ID$APP_FILE_BUNDLE_DISPLAY_NAME$APP_FILE_ITEM_NAME" ]
	then
		print_row "$APP_FILE_ITEM_NAME" "$APP_FILE_BUNDLE_DISPLAY_NAME" "$APP_FILE_APPLE_ID"
	else
		APP_FILE_NAME=$( basename "$APP_FILE" )
		INVALID_APP_FILES="$INVALID_APP_FILES$APP_FILE_NAME\n"
	fi
done

print_row "$DASHES" "$DASHES" "$DASHES"
echo ""

if [ ! -z "$INVALID_APP_FILES" ]
then
	echo "Some files could not be processed:"
	printf "$INVALID_APP_FILES"
	echo ""
fi

IFS="$OIFS"