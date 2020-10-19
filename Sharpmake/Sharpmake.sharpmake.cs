﻿using System;
using System.IO;
using System.Linq;
using System.Reflection;
using Sharpmake;

namespace SharpmakeGen
{
    [Generate]
    public class SharpmakeProject : Common.SharpmakeLibProject
    {
        public SharpmakeProject()
        {
            Name = "Sharpmake";

            // indicates where to find the nuget(s) we reference without needing nuget.config or global setting
            CustomProperties.Add("RestoreAdditionalProjectSources", "https://api.nuget.org/v3/index.json");
        }

        public override void ConfigureAll(Configuration conf, Target target)
        {
            base.ConfigureAll(conf, target);
            conf.ProjectPath = @"[project.SourceRootPath]";

            conf.Options.Add(Options.CSharp.AllowUnsafeBlocks.Enabled);
            conf.ReferencesByNuGetPackage.Add("Microsoft.Build.Utilities.Core", "16.7.0");
            conf.ReferencesByNuGetPackage.Add("Microsoft.CodeAnalysis.CSharp", "3.4.0");
            conf.ReferencesByNuGetPackage.Add("Microsoft.VisualStudio.Setup.Configuration.Interop", "2.3.2262-g94fae01e");
        }
    }
}
