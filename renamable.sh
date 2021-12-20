#!/bin/bash

# rename_remarkable_files
# Remarkable uses UUIDs as filenames for stored PDFs. 
# This script creates a valid filename based upon the "visible name"
# and saves the named PDF in the directory of your choosing. 
# Otherwise the files will be stored in ~/.remarkable/pdf

# Set this to your backups folder
# This is what I have happened to choose

# TODO
# - POSIX compatable 
# - Handle 2 pdfs of the same name being created.
# - Handle copying all vs copying diff
# - Perhaps ssh connect / pull / rename for connected Remarkable
# - More proper handling of non-ASCII characters
# - Check if valid directory

# REMARKABLE_BACKUP is the directory containing the stored *.pdf and *.metadata files
if [ -z "$REMARKABLE_BACKUP" ]; then
    REMARKABLE_BACKUP="${HOME}/remarkable-backup/files"
else
    REMARKABLE_BACKUP="${REMARKABLE_BACKUP%\/}"
fi

if [ -z "$RENAMABLE_LOCATION" ]; then
    RENAMABLE_LOCATION="${HOME}/renamable"
else
    RENAMABLE_LOCATION="${RENAMABLE_LOCATION%\/}"
fi

for pdf_loc in ${REMARKABLE_BACKUP}/*.pdf; do
    pdf_file="${pdf_loc##*/}"
    uuid="${pdf_file%.pdf}"
    if [[ ${uuid//-/} =~ ^[[:xdigit:]]{32}$ ]]; then
        new_name=$(grep "visibleName" "${REMARKABLE_BACKUP}"/"${uuid}".metadata | # find visibleName of uuid.metadata file
                  cut -d '"' -f 4 | # Get the quoted value of VisibleName line
                  sed -e "s/ /_/g" -e "s/[^A-Za-z0-9_-]//g" -e "s/__*/_/g" -e "s/.pdf$//" | # Change formatted string
                  colrm 251) # Keep below filename max
        eval cp $pdf_loc ${RENAMABLE_LOCATION}/${new_name}.pdf
        echo "Added ${new_name}"
    fi
done    
