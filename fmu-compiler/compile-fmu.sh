#!/bin/bash
ORIGINAL_DIR="$(pwd)"

export OSXCROSS_ROOT=/opt/osxcross/target
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

    /opt/cmake-3.5.1-Linux-x86_64/bin/cmake  -B$B -H$1 -DCMAKE_TOOLCHAIN_FILE=`readlink -f toolchains/osx-gcc.cmake` -DOSXCROSS_ROOT=$OSXCROSS_ROOT 

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

    CFLAGS=-m32 CXXFLAGS=-m32 cmake -B$B -H$1

    make -C $B		
}

function assemble
{

    B=$1/build/

    mkdir -p $B/fmu/{binaries,resources,sources}

    mkdir -p $B/fmu/binaries/{darwin64,win32,win64,linux32,linux64}

    echo Copying files...
    cp $1/modelDescription.xml $B/fmu/

    if [ -e "$1/resources" ] 
    then
        cp -r $1/resources $B/fmu/
    fi

    cp -r $1/sources/* $B/fmu/sources/

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


# read defines if any
if [ -e "$WD/sources/defines.def" ] 
then

    defs=""

    while IFS='' read -r line || [[ -n "$line" ]]; do
        echo "Text read from file: $line"
        defs="$defs -D$line"
    done < "$WD/sources/defines.def"


    defs="add_definitions(${defs})"

    sed -i "s/##DEFINITIONS##/${defs}/g" $WD/CMakeLists.txt


fi

# read additional includes if any
if [ -e "$WD/sources/includes.txt" ] 
then

    includes=""

    while IFS='' read -r line || [[ -n "$line" ]]; do
        echo "Text read from file: $line"
        includes="$includes sources/$line"
    done < "$WD/sources/includes.txt"


    includes="include_directories(${includes})"
    echo "additional includes ${includes}"
    sed -i "s|##INCLUDES##|${includes}|g" $WD/CMakeLists.txt


fi

echo "###########################################################"
echo  CMakeLists.txt
echo  "---------------------------------------------------------"
cat  $WD/CMakeLists.txt


echo "###########################################################"
echo "###########################################################"


filename="${filename%.*}"
extension="${filename##*.}"

# Extract FMU name from the modelIdentifier attribute within the CoSimulation tag
export FMU_NAME=`xmllint --xpath "string(//CoSimulation//@modelIdentifier)" "$WD/modelDescription.xml"`

export FMI_INCLUDES=`readlink -f includes`

#Read the values of the name attribute and scrap everything else:
#<SourceFiles><File name="x1.c"/><File name="x2.c"/></SourceFiles>
#thus SOURCES=x1.c x2.c.



#Note -r is an argument to sed, which allows the alternation operator |. This is -E for MAC.
SOURCES=`xmllint --xpath "//CoSimulation//SourceFiles//File//@name" "$WD/modelDescription.xml" | sed -r -e "s|(name=\")|$WD/sources/|g" | sed "s/\"//g" | sed "s|^ *||g"`
echo "Sources: $SOURCES"
export SOURCES=$SOURCES

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
