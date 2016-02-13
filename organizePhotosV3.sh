#!/bin/bash

# Check to see if zenity and exiftool is installed
# (solution copied from http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script)
type zenity >/dev/null 2>&1 || { echo >&2 "This script requires zenity but it's not installed.  Aborting."; exit; }
type exiftool >/dev/null 2>&1 || { echo >&2 "This script requires exiftool but it's not installed.  Aborting."; zenity --error --text "exiftool is not installed. Please install and try again. \nScript will exit"; exit; }

# The directory where the photos are
echo "Please select a source folder"
SOURCE_DIR=$(zenity --file-selection --directory --title="SELECT A SOURCE FOLDER")
echo "Source folder is: $SOURCE_DIR"

# The destination directory
echo "Please select the destination folder"
DEST_DIR=$(zenity --file-selection --directory --title="SELECT A DESTINATION FOLDER")
echo "Destination folder is: $DEST_DIR"

# Confirmation dialog
if zenity --question --ok-label="OK" --cancel-label="Cancel" --text '<span foreground="red" font="12"> Source folder is \n<b>'$SOURCE_DIR'</b> \n\nDestination folder is \n<b>'$DEST_DIR'</b></span>'; then
	echo "Continuing normally"
else
	exit
fi

# Extra subfolder
DEST_SUBFOLDER=$(zenity --entry --text="Name of subfolder" --title="Add the name of the subfolder (leave blank for none)")
DEST_SUBFOLDER_RAW=RAW

# The date pattern for the destination dir (see strftime)
DEST_DIR_PATTERN="%Y%m%d"

# Copy or move all files having this extension
EXTENSION=jpg
EXTENSION_RAW=cr2

# Select to copy or move the files, or cancel and exit
OPERATION=$(zenity --list --text "Would you like to move or copy the files?" --radiolist --column "Select" --column "Operation" TRUE Copy FALSE Move FALSE "Cancel and Exit")

#Operation for the jpg images
# TODO: Need to correct this as it is here: https://github.com/koalaman/shellcheck/wiki/SC2044
for f in $(find "$SOURCE_DIR" -iname "*.$EXTENSION" -type f); do
# Obtain the creation date from the EXIF tag
f_date=$(exiftool "$f" -ModifyDate -d $DEST_DIR_PATTERN | cut -d ':' -f 2 | sed -e 's/^[ \t]*//;s/[ \t]*$//');

# The destination directories with or without subfolder
f_dest_dir="$DEST_DIR/$f_date"
f_dest_dir_final="$DEST_DIR/$f_date/$DEST_SUBFOLDER"

# Create the directory if it doesn't exist
if [ ! -d "$f_dest_dir" ]; then
echo "Creating directory $f_dest_dir"
mkdir "$f_dest_dir"
fi

# Create the subfolder if you typed a subfolder name
# TODO: if there is no input for a subfolder, skip this step
if [ ! -d "$f_dest_dir_final" ]; then
echo "Creating directory $f_dest_dir_final"
mkdir "$f_dest_dir_final"
fi

# Copy or Move the files, depending on what was selected before, or Cancel and exit if it was selected
case $OPERATION in
	"Copy")
	echo "Copying $f to $f_dest_dir_final"
	cp -v "$f" "$f_dest_dir_final"
	;;
	"Move")
	echo
	"Moving $f to $f_dest_dir_final"
	mv -v "$f" "$f_dest_dir_final"
	;;
	"Cancel and Exit")
	echo "Operation cancelled. Exiting"
	exit
	;;
esac

done

#Operation for raw images (cr2)
for f_raw in $(find "$SOURCE_DIR" -iname "*.$EXTENSION_RAW" -type f); do
# Obtain the creation date from the EXIF tag
f_date_raw=$(exiftool "$f_raw" -ModifyDate -d $DEST_DIR_PATTERN | cut -d ':' -f 2 | sed -e 's/^[ \t]*//;s/[ \t]*$//');

f_dest_dir_final_raw="$DEST_DIR/$f_date_raw/$DEST_SUBFOLDER/$DEST_SUBFOLDER_RAW"

if [ ! -d "$f_dest_dir_final_raw" ]; then
echo "Creating directory $f_dest_dir_final_raw"
mkdir -p "$f_dest_dir_final_raw"
fi

case $OPERATION in
	"Copy")
	echo "Copying $f_raw to $f_dest_dir_final_raw"
	cp -v "$f_raw" "$f_dest_dir_final_raw"
	;;
	"Move")
	echo "Moving $f_raw to $f_dest_dir_final_raw"
	mv -v "$f_raw" "$f_dest_dir_final_raw"
	;;
esac

done

zenity --info --text="Operation complete. Please check folders for errors."
