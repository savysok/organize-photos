#!/bin/bash

# Check to see if zenity and exiftool is installed
# (copied from http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script)
type exiftool >/dev/null 2>&1 || { echo >&2 "This script requires exiftool but it's not installed.  Aborting."; }
type zenity >/dev/null 2>&1 || { echo >&2 "This script requires zenity but it's not installed.  Aborting."; }

# The directory where the photos are
echo "Please select a source folder"
SOURCE_DIR=$(zenity --file-selection --directory --title="SELECT A SOURCE FOLDER")
echo "Source folder is: $SOURCE_DIR"

# The destination directory
echo "Please select the destination folder"
DEST_DIR=$(zenity --file-selection --directory --title="SELECT A DESTINATION FOLDER")
echo "Destination folder is: $DEST_DIR"

zenity --info --text "Source folder is $SOURCE_DIR. Destination folder is $DEST_DIR"

# Extra subfolder
DEST_SUBFOLDER=$(zenity --entry --text="Name of subfolder" --title="Add the name of the subfolder (leave blank for none)")
DEST_SUBFOLDER_RAW=RAW

# The date pattern for the destination dir (see strftime)
DEST_DIR_PATTERN="%Y%m%d"

# Move all files having this extension
EXTENSION=jpg
EXTENSION_RAW=cr2

# Move or copy the files
OPERATION=$(zenity --list --text "Would you like to move or copy the files?" --radiolist --column "Select" --column "Operation" TRUE Copy FALSE Move)

#Operation for jpg images
for f in $(find "$SOURCE_DIR" -iname "*.$EXTENSION" -type f); do
# Obtain the creation date from the EXIF tag
f_date=$(exiftool "$f" -ModifyDate -d $DEST_DIR_PATTERN | cut -d ':' -f 2 | sed -e 's/^[ \t]*//;s/[ \t]*$//');

# Construct and create the destination directory
f_dest_dir="$DEST_DIR/$f_date"
f_dest_dir_final="$DEST_DIR/$f_date/$DEST_SUBFOLDER"

if [ ! -d "$f_dest_dir" ]; then
echo "Creating directory $f_dest_dir"
mkdir "$f_dest_dir"
fi

if [ ! -d "$f_dest_dir_final" ]; then
echo "Creating directory $f_dest_dir_final"
mkdir "$f_dest_dir_final"
fi

case $OPERATION in
	"Copy")
	echo "Copying $f to $f_dest_dir_final"
	cp -Rv "$f" "$f_dest_dir_final"
	;;
	"Move")
	echo
	"Moving $f to $f_dest_dir_final"
	mv -Rv "$f" "$f_dest_dir_final"
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
	cp -Rv "$f_raw" "$f_dest_dir_final_raw"
	;;
	"Move")
	echo "Moving $f_raw to $f_dest_dir_final_raw"
	mv -Rv "$f_raw" "$f_dest_dir_final_raw"
	;;
esac

done

zenity --info \
	--text="Operation complete. Please check folders for errors."
