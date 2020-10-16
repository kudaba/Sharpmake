using System;
using System.IO;
using System.Linq;
using System.Reflection;
using Sharpmake;

namespace SharpmakeGen
{
    [Generate]
    public class SharpmakeApplicationProject : Common.SharpmakeAppProject
    {
        public SharpmakeApplicationProject()
            : base(generateXmlDoc: false)
        {
            Name = "Sharpmake.Application";
            ApplicationManifest = "app.manifest";

            DependenciesCopyLocal = DependenciesCopyLocalTypes.Default;
        }

        public override void ConfigureAll(Configuration conf, Target target)
        {
            base.ConfigureAll(conf, target);

            conf.Output = Configuration.OutputType.DotNetConsoleApp;

            conf.Options.Add(Options.CSharp.AutoGenerateBindingRedirects.Enabled);

            conf.ReferencesByName.Add("System.Windows.Forms");

            var libTarget = target.Clone(Common.DefaultLibDotNetFramework);
            conf.AddPrivateDependency<SharpmakeProject>(libTarget);
            conf.AddPrivateDependency<SharpmakeGeneratorsProject>(libTarget);
            conf.AddPrivateDependency<Platforms.CommonPlatformsProject>(libTarget);
        }
    }
}
