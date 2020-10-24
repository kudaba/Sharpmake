#!/usr/bin/env bash

function success {
	echo Bootstrap succeeded \!
	exit 0
}

function error {
	echo Bootstrap failed \!
	exit 1
}

# fail immediately if anything goes wrong
# set -e

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

which dotnet > /dev/null
DOTNET_FOUND=$?
if [ $DOTNET_FOUND -ne 0 ]; then
    echo "dotnet not found, see https://dotnet.microsoft.com/download"
    error
fi

SHARPMAKE_MAIN="${1:-"$CURRENT_DIR/Sharpmake.Main.sharpmake.cs"}"

$CURRENT_DIR/CompileSharpmake.sh $CURRENT_DIR/Sharpmake.Application/Sharpmake.Application.csproj Debug
if [ $? -ne 0 ]; then
    echo "The build has failed."
    if [ -f $SHARPMAKE_EXECUTABLE ]; then
        echo "A previously built sharpmake exe was found at '${SHARPMAKE_EXECUTABLE}', it will be reused."
    fi
fi

echo "Generating Sharpmake solution..."
SM_CMD="tmp/bin/Debug/Sharpmake.Application/Sharpmake.Application /sources\(\'${SHARPMAKE_MAIN}\'\) /verbose"

# the following line should have been enough but makes the compilation fail on appveyor, seems like the csproj properties are not applied, probably a bug
#SM_CMD="dotnet run --verbosity m --project Sharpmake.Application/Sharpmake.Application.csproj --configuration Debug /sources\(\'${SHARPMAKE_MAIN}\'\) /verbose"
echo $SM_CMD
eval $SM_CMD || error

success
