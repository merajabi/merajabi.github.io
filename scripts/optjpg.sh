#!/bin/bash
path=$1
size=$2
compress=$3
name=$4

echo "usage: optjpg.sh fullpath compression-ratio generated-filename";
echo

list=$(ls $path/* | grep -P ".+\.(:?png|jpeg|jpg)")

if [ -z "$compress" ]; then
	compress="85";
fi;

if [ -z "$size" ]; then
	size="640x480"; # 1920x1280 960x640 640x480 320x240 170x120
fi;

i=0
for ff in $list
	do
		fntmp=${ff#.}		

		if [ ! -z "$name" ];then
			fn="$name-$i";
		else
		#	fn=`expr match "$fntmp" '.*?\(\w+\)\.\(jpg\|jpeg\)$'`;
			fn=$(echo $fntmp |grep -Po "[\w-]+\.(:jpg|jpeg|png)$" | grep -Po "^[\w-]+" )
		fi;

		fn=${fn,,}

		convert -resize $size $fntmp $path/$fn-$size.jpg
#		jpegoptim --strip-all -t -f --max=$compress -d opt $fn-$size.jpg
		jpegoptim --strip-all -t -f --max=$compress $path/$fn-$size.jpg

		i=$(($i+1));
	done;

