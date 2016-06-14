#!/bin/bash
ORIGINAL_DIR="$(pwd)"

cd "$(dirname "$0")"

set -e

#input must be a zip with a source folder
INPUT=$1


function compileDarwin
{

		echo Building Darwin .dylib
		B=$1/build/darwin

		rm -rf $B
		mkdir -p $B

		cmake  -B$B -H$1 -DCMAKE_TOOLCHAIN_FILE=`readlink -f toolchains/osx-gcc.cmake` -DOSXCROSS_ROOT=$OSXCROSS_ROOT

		make -C $B

}

function compileWin32
{

		echo Building Win32 .dll
		B=$1/build/win32

		rm -rf $B
		mkdir -p $B

		cmake  -B$B -H$1 -DCMAKE_TOOLCHAIN_FILE=`readlink -f toolchains/cmake-toolchains/Toolchain-Ubuntu-mingw32.cmake`

		make -C $B

}

function compileWin64
{

		echo Building Win64 .dll
		B=$1/build/win64

		rm -rf $B
		mkdir -p $B

		cmake  -B$B -H$1 -DCMAKE_TOOLCHAIN_FILE=`readlink -f toolchains/cmake-toolchains/Toolchain-Ubuntu-mingw64.cmake`

		make -C $B

}

function compileLinux64
{
		echo Building Linux x64 .so
		B=$1/build/linux64
		rm -rf $B
		mkdir -p $B

		cmake  -B$B -H$1

		make -C $B
}

function compileLinux32
{
		echo Building Linux x32 .so
		B=$1/build/linux32

		rm -rf $B
		mkdir -p $B

		cmake -B$B -H$1 -DLINK_FLAGS="-m32" -DCFLAGS="-m32"

		make -C $B		
}

function assemble
{

B=$1/build/

mkdir -p $B/fmu/{binaries,resources,sources}

mkdir -p $B/fmu/binaries/{darwin64,win32,win64,linux32,linux64}

echo Copying files...
cp $1/modelDescription.xml $B/fmu/
cp -r $1/resources $B/fmu/
cp $1/sources/*.* $B/fmu/sources/

BIN=$B/fmu/binaries
cp $B/darwin/*.dylib $BIN/darwin64/
cp $B/linux64/*.so $BIN/linux64/
cp $B/linux32/*.so $BIN/linux32/
cp $B/win64/*.dll $BIN/win64/
cp $B/win32/*.dll $BIN/win32/

echo Zipping...

curdir="$PWD"

cd $B/fmu/
zip -r $2 .

cd $curdir
}


WD=`mktemp -d -t 'fmu.XXXXXXXXXX'`

unzip $INPUT -d $WD

#rm $INPUT

D=$WD
echo "Folder is ${D}"


#filename=$(basename "$INPUT")
filename=$2
#name=`echo $D| sed 's|\./||g'`

cp CMakeLists.txt $WD
cp -r toolchains $WD

filename="${filename%.*}"
extension="${filename##*.}"

export FMU_NAME=$filename
export FMI_INCLUDE=`readlink -f includes`

compileDarwin $D
compileLinux64 $D
compileLinux32 $D
compileWin64 $D
compileWin32 $D

outputName=$WD/${filename}.fmu
assemble $D $outputName

echo Done
readlink -f $outputName
cd $ORIGINAL_DIR
