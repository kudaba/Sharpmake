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
set -e

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

which msbuild > /dev/null
MSBUILD_FOUND=$?
if [ $MSBUILD_FOUND -ne 0 ]; then
    echo "MSBuild not found"
    error
fi

# workaround for https://github.com/mono/mono/issues/6752
TERM=xterm

SHARPMAKE_MAIN="${1:-"$CURRENT_DIR/Sharpmake.Main.sharpmake.cs"}"

$CURRENT_DIR/CompileSharpmake.sh $CURRENT_DIR/Sharpmake.Application/Sharpmake.Application.csproj Debug AnyCPU
if [ $? -ne 0 ]; then
    echo "The build has failed."
    if [ -f $SHARPMAKE_EXECUTABLE ]; then
        echo "A previously built sharpmake exe was found at '${SHARPMAKE_EXECUTABLE}', it will be reused."
    fi
fi

echo "Generating Sharpmake solution..."
SM_CMD="dotnet tmp/bin/Debug/Sharpmake.Application/Sharpmake.Application.dll /sources\(\'${SHARPMAKE_MAIN}\'\) /verbose"
#SM_CMD="dotnet run --verbosity m --project Sharpmake.Application/Sharpmake.Application.csproj --configuration Debug /sources\(\'${SHARPMAKE_MAIN}\'\) /verbose"
echo $SM_CMD
eval $SM_CMD || error

success
