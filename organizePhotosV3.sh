#!/bin/bash

# The directory where the photos are
SOURCE_DIR=$(zenity --file-selection --directory --title="SELECT A SOURCE FOLDER")

# The destination directory
DEST_DIR=$(zenity --file-selection --directory --title="SELECT A DESTINATION FOLDER")

# Extra subfolder
DEST_SUBFOLDER=$(zenity --entry --text="Name of subfolder" --title="Add the name of the subfolder (leave blank for none)")
DEST_SUBFOLDER_RAW=RAW

# The date pattern for the destination dir (see strftime)
DEST_DIR_PATTERN="%Y%m%d"

# Move all files having this extension
EXTENSION=jpg
EXTENSION_RAW=cr2

# Move or copy the files
#OPERATION=`zenity --entry --text="Would you like to move or copy the files? (mv for move, cp for copy)" --title="Method of operation"`
OPERATION=$(zenity  --list  --text "Would you like to move or copy the files? (mv for move, cp for copy)" --radiolist  --column "Select" --column "Operation" TRUE cp FALSE mv)

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

$OPERATION "$f" "$f_dest_dir_final"

if [ "$OPERATION" = cp ]; then
echo "Copying $f to $f_dest_dir_final"
else
echo "Moving $f to $f_dest_dir_final"
fi

done

#Operation for raw images (cr2)
for f_raw in $(find "$SOURCE_DIR" -iname "*.$EXTENSION_RAW" -type f); do
# Obtain the creation date from the EXIF tag
f_date_raw=$(exiftool "$f_raw" -ModifyDate -d $DEST_DIR_PATTERN | cut -d ':' -f 2 | sed -e 's/^[ \t]*//;s/[ \t]*$//');

f_dest_dir_final_raw="$DEST_DIR/$f_date_raw/$DEST_SUBFOLDER/$DEST_SUBFOLDER_RAW"

if [ ! -d "$f_dest_dir_final_raw" ]; then
echo "Creating directory $f_dest_dir_final_raw"
mkdir "$f_dest_dir_final_raw"
fi

$OPERATION "$f_raw" "$f_dest_dir_final_raw"

if [ "$OPERATION" = cp ]; then
echo "Copying $f_raw to $f_dest_dir_final_raw"
else
echo "Moving $f_raw to $f_dest_dir_final_raw"
fi

done

zenity --info \
	--text="Operation complete. Please check folders for errors."
