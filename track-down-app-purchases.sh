#!/bin/bash

# Track Down App Purchases v0.1.1
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

function plutil_installed
{
	hash plutil 2> /dev/null
}

function extract_plist_key
{
	local KEY=$1
	local PLIST=$2
	echo "$PLIST" | sed -e "/<key>$KEY<\\/key>/I,/<string>/I!d" | sed -En "s/^.*<string>(.+)<\\/string>.*$/\\1/Ip"
}

function extract_plist
{
	local PLIST_NAME=$1
	local ZIP_NAME=$2
	local UNZIP_COMMAND="unzip -p \"$ZIP_NAME\" \"$PLIST_NAME\" 2> /dev/null"
	
	if plutil_installed
	then
		eval "$UNZIP_COMMAND" | plutil -convert xml1 -o - -
	else
		eval "$UNZIP_COMMAND"
	fi
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
	APP_PLIST=$( extract_plist "iTunesMetadata.plist" "$APP_FILE" )
	APP_APPLE_ID=$( extract_plist_key "appleId" "$APP_PLIST" )
	APP_BUNDLE_DISPLAY_NAME=$( extract_plist_key "bundleDisplayName" "$APP_PLIST" )
	APP_ITEM_NAME=$( extract_plist_key "itemName" "$APP_PLIST" )
	
	if [ ! -z "$APP_APPLE_ID$APP_BUNDLE_DISPLAY_NAME$APP_ITEM_NAME" ]
	then
		print_row "$APP_ITEM_NAME" "$APP_BUNDLE_DISPLAY_NAME" "$APP_APPLE_ID"
	else
		APP_FILE_NAME=$( basename "$APP_FILE" )
		INVALID_APP_FILES="• $INVALID_APP_FILES$APP_FILE_NAME\n"
	fi
done

print_row "$DASHES" "$DASHES" "$DASHES"
echo ""

if [ ! -z "$INVALID_APP_FILES" ]
then
	echo "Some files could not be processed:"
	printf "$INVALID_APP_FILES"
	echo ""
	
	if ! plutil_installed
	then
		echo "You could try to install the Xcode Command Line Tools. It includes a utility"
		echo "that can convert binary plist files to their XML equivalent. In short, it might"
		echo "help this script process more of your apps."
		echo ""
		echo "Start by installing Xcode from the Mac App Store (for free). Then, go to the"
		echo "Downloads tab within the Xcode Preferences menu and click \"Install\" next to the"
		echo "Command Line Tools entry."
		echo ""
		echo "More information and source: https://developer.apple.com/support/xcode/"
		echo ""
	fi
fi

IFS="$OIFS"