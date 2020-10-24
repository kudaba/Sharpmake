#!/bin/bash

SuccessWait() {
    echo -e "\e[92m$@\e[0m"
    sleep 5
}

ErrorWait() {
    echo -e "\e[31m$@\e[0m"
    read -p "Press [Enter] key to exit..."
}

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
$CURRENT_DIR/CompileSharpmake.sh $CURRENT_DIR/Sharpmake.Application/Sharpmake.Application.csproj Debug

errorlevel=$?
if [ ! $errorlevel -eq 0 ]; then
    ErrorWait "Failed to build Sharpmake"
    exit 1
fi

SHARPMAKE_EXECUTABLE="$CURRENT_DIR/tmp/bin/Debug/Sharpmake.Application/Sharpmake.Application"

if [ ! -f $SHARPMAKE_EXECUTABLE ]; then
    ErrorWait "Cannot find sharpmake executable in $CURRENT_DIR/tmp/bin"
    exit 1
fi

echo Using executable $SHARPMAKE_EXECUTABLE

# function Update the reference folder thats used for regression tests
updateref()
{
    testRoot=$1
    testFolder=$2
    testFile=$3
    outDir=$4
    remapRoot=$5

    pushd "$CURRENT_DIR/$testRoot"

    echo Updating references of $testFolder...
    rm -rf "$testFolder/$outDir"
    $SHARPMAKE_EXECUTABLE "/sources('$testFolder/$testFile') /outputdir('$testFolder/$outDir') /remaproot('$remapRoot') /verbose"
    errorlevel=$?

    # restore caller current directory
    popd

    if [ ! $errorlevel -eq 0 ]; then
        ErrorWait "Failed to update $testFolder"
        exit 1
    fi
}

# Source file is .sh so line endings are lf instead of crlf
exec 3< $CURRENT_DIR/UpdateSamplesOutputSource.sh
while IFS= read -u 3 -r line
do
    args=(${line//;/ })
    updateref ${args[0]} ${args[1]} ${args[2]} reference ${args[3]}
done

SuccessWait "References update succeeded!"