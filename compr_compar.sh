#!/bin/bash

# compression methods comparation
# compared methods: zip, gzip, bzip2, xz
# compared file types:
# 	1MB random text sample
#	included sample picture (rgb.png)
#	standard binary file (/bin/ls)

# Disk space test
# actual volume testing
# =====================================

# enter standalone working directory to eliminate file corruptions
mkdir cc_wd
cd cc_wd

echo "Disk space test..."

echo -n "Free volume space: "
space=$(df -B1 . | tail -1 | tr -s " " " " | cut -d " " -f 4)
echo $space

echo -n "Minimal required volume space: "
picsize=$(stat -c%s ../rgbsamp.png) > compr_compar_suppressed_log
binsize=$(stat -c%s /bin/ls) >> compr_compar_suppressed_log
randsize=1048576
reqsize=$((($picsize + $binsize + 1048576)*12))		#minimal 12-times of max size before compression
echo $reqsize

if [ $space -gt $reqsize ]; then
	echo -e "PASS\n"

# =====================================
# Create files for process and archive them

dd status=none if=/dev/urandom of=random_sample bs=1M count=1 >> compr_compar_suppressed_log
cp /bin/ls ls_copy >> compr_compar_suppressed_log
cp ../rgbsamp.png rgb.png >> compr_compar_suppressed_log

# Archive files - custom output

echo "random text sample processing..."
zip -k random_sample.zip random_sample >> compr_compar_suppressed_log
gzip -k random_sample >> compr_compar_suppressed_log
bzip2 -k random_sample >> compr_compar_suppressed_log
xz -k random_sample >> compr_compar_suppressed_log
echo "random text sample compresed"

echo "binary file sample processing..."
zip -k ls_copy.zip ls_copy >> compr_compar_suppressed_log
gzip -k ls_copy >> compr_compar_suppressed_log
bzip2 -k ls_copy >> compr_compar_suppressed_log
xz -k ls_copy >> compr_compar_suppressed_log
echo "binary file sample compresed"

echo "image file sample processing..."
zip -k rgb.png.zip rgb.png >> compr_compar_suppressed_log
gzip -k rgb.png >> compr_compar_suppressed_log
bzip2 -k rgb.png >> compr_compar_suppressed_log
xz -k rgb.png >> compr_compar_suppressed_log
echo "image file sample compresed"
echo -e "\nSuppresed output saved in archcomp_script_log.txt"

# Size of compressed files
# suppressed output
# =====================================

# zip
zippicsize=$(stat -c%s rgb.png.zip) >> compr_compar_suppressed_log
zipbinsize=$(stat -c%s ls_copy.zip) >> compr_compar_suppressed_log
ziprandsize=$(stat -c%s random_sample.zip) >> compr_compar_suppressed_log

# bzip2
bzip2picsize=$(stat -c%s rgb.png.bz2) >> compr_compar_suppressed_log
bzip2binsize=$(stat -c%s ls_copy.bz2) >> compr_compar_suppressed_log
bzip2randsize=$(stat -c%s random_sample.bz2) >> compr_compar_suppressed_log

# gzip
gzippicsize=$(stat -c%s rgb.png.gz) >> compr_compar_suppressed_log
gzipbinsize=$(stat -c%s ls_copy.gz) >> compr_compar_suppressed_log
gziprandsize=$(stat -c%s random_sample.gz) >> compr_compar_suppressed_log

# xz
xzpicsize=$(stat -c%s rgb.png.xz) >> compr_compar_suppressed_log
xzbinsize=$(stat -c%s ls_copy.xz) >> compr_compar_suppressed_log
xzrandsize=$(stat -c%s random_sample.xz) >> compr_compar_suppressed_log

# =====================================
# Print results

divider==================================================
divider=$divider$divider

header="\n %-18s %14s %14s %14s %10s %10s\n"
format=" %-18s %14s %14s %14s %10s %10s\n"

width=86

printf "$header" "FILE" "ORIG_SIZE" "COMPR_SIZE" "COMPR_DIF" "C_RATIO" "METHOD"

printf "%$width.${width}s\n" "$divider"

printf "$format" \
rgb.png.zip $picsize $zippicsize $((zippicsize-picsize)) $((zippicsize*100/picsize))% "ZIP" \
rgb.png.bz2 $picsize $bzip2picsize $((bzip2picsize-picsize)) $((bzip2picsize*100/picsize))% "BZIP2" \
rgb.png.gzip $picsize $gzippicsize $((gzippicsize-picsize)) $((gzippicsize*100/picsize))% "GZIP" \
rgb.png.xz $picsize $xzpicsize $((xzpicsize-picsize)) $((xzpicsize*100/picsize))% "XZ"
printf "%$width.${width}s\n" "$divider"

printf "$format" \
ls_copy.zip $binsize $zipbinsize $((zipbinsize-binsize)) $((zipbinsize*100/binsize))% "ZIP" \
ls_copy.bz2 $binsize $bzip2binsize $((bzip2binsize-binsize)) $((bzip2binsize*100/binsize))% "BZIP2" \
ls_copy.gzip $binsize $gzipbinsize $((gzipbinsize-binsize)) $((gzipbinsize*100/binsize))% "GZIP" \
ls_copy.xz $binsize $xzbinsize $((xzbinsize-binsize)) $((xzbinsize*100/binsize))% "XZ"
printf "%$width.${width}s\n" "$divider"

printf "$format" \
random_sample.zip $randsize $ziprandsize $((ziprandsize-randsize)) $((ziprandsize*100/randsize))% "ZIP" \
random_sample.bz2 $randsize $bzip2randsize $((bzip2randsize-randsize)) $((bzip2randsize*100/randsize))% "BZIP2" \
random_sample.gzip $randsize $gziprandsize $((gziprandsize-randsize)) $((gziprandsize*100/randsize))% "GZIP" \
random_sample.xz $randsize $xzrandsize $((xzrandsize-randsize)) $((xzrandsize*100/randsize))% "XZ"
printf "%$width.${width}s\n" "$divider"


# Remove created files
mv compr_compar_suppressed_log ..
cd ..
rm -r cc_wd

echo -e "\nDONE\nSuppresed output saved in compr_compar_suppressed_log file."

else
	echo -e "FAILED \nTerminated"
	exit
fi