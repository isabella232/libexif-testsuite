#!/bin/sh
# Checks tag description lookup. Only tests a representative sample of
# tags, especially those that test some potential boundary conditions
# of the lookup routines.

. check-vars.sh
tmpfile="./output.tmp"

# clear out the output file
rm -f "$tmpfile"

# List the tags to test
TESTTAGS_GPS="0"   # first in table
TESTTAGS_GPS=$TESTTAGS_GPS" 1"  # same number as in Interoperability IFD

TESTTAGS_Interoperability="1"   # same number as in GPS IFD

TESTTAGS_0="1"                  # doesn't exist in this IFD
TESTTAGS_0=$TESTTAGS_0" 0x100"  # first in table for this IFD
TESTTAGS_0=$TESTTAGS_0" 0xfe"   # exists in table, but not marked as usable in any IFD
TESTTAGS_0=$TESTTAGS_0" 0x8769" # entry for a sub-IFD
				# This currently prints an empty description,
				# which is really a bug in libexif.

TESTTAGS_1="0x0201"             # only exists in IFD 1

TESTTAGS_EXIF=$TESTTAGS_EXIF" 0x0201" # only exists in IFD 1, not EXIF IFD
TESTTAGS_EXIF=$TESTTAGS_EXIF" 0xa420" # last in table associated with an IFD
TESTTAGS_EXIF=$TESTTAGS_EXIF" 0xc4a5" # last in table (not associated with IFD)

for ifd in GPS Interoperability 0 1 EXIF; do
	TESTTAGS=`eval echo \\$TESTTAGS_${ifd}`
	for tag in $TESTTAGS; do
		echo Testing IFD $ifd tag $tag
		env LANG=C LANGUAGE=C "$EXIFEXE" --tag=$tag --ifd=$ifd -s >>"$tmpfile"
	done
done

diff "$tmpfile" - <<EOF
Tag 'GPS tag version' (0x0000, 'GPSVersionID'): Indicates the version of <GPSInfoIFD>. The version is given as 2.0.0.0. This tag is mandatory when <GPSInfo> tag is present. (Note: The <GPSVersionID> tag is given in bytes, unlike the <ExifVersion> tag. When the version is 2.0.0.0, the tag value is 02000000.H).
Tag 'North or South Latitude' (0x0001, 'GPSLatitudeRef'): Indicates whether the latitude is north or south latitude. The ASCII value 'N' indicates north latitude, and 'S' is south latitude.
Tag 'Interoperability Index' (0x0001, 'InteroperabilityIndex'): Indicates the identification of the Interoperability rule. Use "R98" for stating ExifR98 Rules. Four bytes used including the termination code (NULL). see the separate volume of Recommended Exif Interoperability Rules (ExifR98) for other tags used for ExifR98.
Tag '' (0x0001, ''): 
Tag 'Image Width' (0x0100, 'ImageWidth'): The number of columns of image data, equal to the number of pixels per row. In JPEG compressed data a JPEG marker is used instead of this tag.
Tag 'New Subfile Type' (0x00fe, 'NewSubfileType'): A general indication of the kind of data contained in this subfile.
Tag '' (0x8769, ''): 
Tag 'JPEG Interchange Format' (0x0201, 'JPEGInterchangeFormat'): The offset to the start byte (SOI) of JPEG compressed thumbnail data. This is not used for primary image JPEG data.
Tag '' (0x0201, ''): 
Tag 'Image Unique ID' (0xa420, 'ImageUniqueID'): This tag indicates an identifier assigned uniquely to each image. It is recorded as an ASCII string equivalent to hexadecimal notation and 128-bit fixed length.
Tag 'PRINT Image Matching' (0xc4a5, 'PrintImageMatching'): Related to Epson's PRINT Image Matching technology
EOF
s="$?"

rm -f "$tmpfile"

exit "$s"
