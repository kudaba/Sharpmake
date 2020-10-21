#!/bin/bash
. ./CompileSharpmake_core.sh

# function Update the reference folder thats used for regression tests
updateref()
{
    testRoot=$1
    testFolder=$2
    testFile=$3
    outDir=$4
    remapRoot=$5

    pushd "$SCRIPTPATH/$testRoot"

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

# First compile sharpmake to insure we are trying to deploy using an executable corresponding to the code.
CompileSharpmake Sharpmake.Application/Sharpmake.Application_Core.csproj Debug
errorlevel=$?

if [ $errorlevel -eq 0 ]; then
    CompileSharpmake Sharpmake_Core.sln Debug
    errorlevel=$?
fi

if [ ! $errorlevel -eq 0 ]; then
    ErrorWait "Failed to build Sharpmake"
    exit 1
fi

if [ ! -f $SHARPMAKE_EXECUTABLE ]; then
    SHARPMAKE_EXECUTABLE=$SHARPMAKE_EXECUTABLE_RELEASE
fi

if [ ! -f $SHARPMAKE_EXECUTABLE ]; then
    ErrorWait "Cannot find sharpmake executable in $SCRIPTPATH/bin"
    exit 1
fi

echo Using executable $SHARPMAKE_EXECUTABLE

updateref samples ConfigureOrder                            main.sharpmake.cs                           reference ConfigureOrder
updateref samples CPPCLI                                    CLRTest.sharpmake.cs                        reference CPPCLI
updateref samples CSharpHelloWorld                          HelloWorld.sharpmake.cs                     reference CSharpHelloWorld
updateref samples HelloWorld                                HelloWorld.sharpmake.cs                     reference HelloWorld
updateref samples CSharpVsix                                CSharpVsix.sharpmake.cs                     reference CSharpVsix
updateref samples CSharpWCF                                 CSharpWCF.sharpmake.cs                      reference CSharpWCF/codebase
updateref samples CSharpImports                             CSharpImports.sharpmake.cs                  reference CSharpImports
updateref samples PackageReferences                         PackageReferences.sharpmake.cs              reference PackageReferences
updateref samples QTFileCustomBuild                         QTFileCustomBuild.sharpmake.cs              reference QTFileCustomBuild
updateref samples FastBuildSimpleExecutable                 FastBuildSimpleExecutable.sharpmake.cs      reference FastBuildSimpleExecutable
updateref samples SimpleExeLibDependency                    SimpleExeLibDependency.sharpmake.cs         reference SimpleExeLibDependency

updateref samples NetCore/DotNetCoreFrameworkHelloWorld     HelloWorld.sharpmake.cs                     reference NetCore/DotNetCoreFrameworkHelloWorld
updateref samples NetCore/DotNetFrameworkHelloWorld         HelloWorld.sharpmake.cs                     reference NetCore/DotNetFrameworkHelloWorld
updateref samples NetCore/DotNetMultiFrameworksHelloWorld   HelloWorld.sharpmake.cs                     reference NetCore/DotNetMultiFrameworksHelloWorld

SuccessWait "References update succeeded!"
