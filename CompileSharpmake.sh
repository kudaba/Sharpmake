#!/usr/bin/env bash
# Script arguments:
# $1: Project/Solution to build
# $2: Target(Normally should be Debug or Release)
# $3: Platform(Optional, Any Cpu when not present. If linux, win, or mac
# $4: BuildType(Optional, pass 'publish' after the platform to publish as a single file, self contained executable. platform must not be Any Cpu)
# if none are passed, defaults to building Sharpmake.sln in Debug|Any CPU

function BuildSharpmake {
    solutionPath=$1
    configuration=$2
    platform=$3
    buildtype=$4

    BUILD_CMD="dotnet publish \"$solutionPath\" -v q -nologo -c \"$configuration\""

    if [ "$platform" != "AnyCpu" ]; then
        BUILD_CMD="$BUILD_CMD -r $platform-x64"
        if [ "$buildtype" = "publish" ]; then
            BUILD_CMD="$BUILD_CMD /p:PublishSingleFile=true /p:PublishTrimmed=true"
        fi
    fi

    echo Compiling $solutionPath in "${configuration}|$platform"...
    echo $BUILD_CMD
    eval $BUILD_CMD
    if [ $? -ne 0 ]; then
        echo ERROR: Failed to compile $solutionPath in "${configuration}|${platform}".
        exit 1
    fi
}

# fail immediately if anything goes wrong
# set -e

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

which dotnet > /dev/null
DOTNET_FOUND=$?
if [ $DOTNET_FOUND -ne 0 ]; then
    echo "dotnet not found, see https://dotnet.microsoft.com/download"
    exit $DOTNET_FOUND
fi

SOLUTION_PATH=${1:-"${CURRENT_DIR}/Sharpmake.sln"}
CONFIGURATION=${2:-"Debug"}
PLATFORM=${3:-"AnyCpu"}
BUILDTYPE=$4

BuildSharpmake "$SOLUTION_PATH" "$CONFIGURATION" "$PLATFORM" "$BUILDTYPE"
