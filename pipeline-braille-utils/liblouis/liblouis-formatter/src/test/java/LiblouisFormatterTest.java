import java.io.File;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertTrue;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.options.MavenArtifactProvisionOption;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.bundle;
import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemPackage;
import static org.ops4j.pax.exam.CoreOptions.systemProperty;
import static org.ops4j.pax.exam.CoreOptions.wrappedBundle;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class LiblouisFormatterTest {
	
	@Inject
	private XProcSpecRunner runner;
	
	@Configuration
	public Option[] config() {
		return options(
			systemProperty("logback.configurationFile").value("file:" + PathUtils.getBaseDir() + "/src/test/resources/logback.xml"),
			systemProperty("org.daisy.pipeline.xproc.configuration").value(PathUtils.getBaseDir() + "/src/test/resources/config-calabash.xml"),
			systemProperty("com.xmlcalabash.config.user").value(""),
			systemPackage("org.w3c.dom.traversal;uses:=\"org.w3c.dom\";version=\"0.0.0.1\""),
			mavenBundle().groupId("org.slf4j").artifactId("slf4j-api").version("1.7.2"),
			mavenBundle().groupId("ch.qos.logback").artifactId("logback-core").version("1.0.11"),
			mavenBundle().groupId("ch.qos.logback").artifactId("logback-classic").version("1.0.11"),
			mavenBundle().groupId("org.apache.felix").artifactId("org.apache.felix.scr").version("1.6.2"),
			mavenBundle().groupId("org.ow2.asm").artifactId("asm-all").version("4.0"),
			mavenBundle().groupId("org.apache.aries").artifactId("org.apache.aries.util").version("1.0.0"),
			mavenBundle().groupId("org.apache.aries.spifly").artifactId("org.apache.aries.spifly.dynamic.bundle").version("1.0.0"),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("saxon-he").versionAsInProject(),
			mavenBundle().groupId("org.slf4j").artifactId("jcl-over-slf4j").versionAsInProject(),
			mavenBundle().groupId("commons-codec").artifactId("commons-codec").versionAsInProject(),
			mavenBundle().groupId("org.apache.httpcomponents").artifactId("httpclient-osgi").versionAsInProject(),
			mavenBundle().groupId("org.apache.httpcomponents").artifactId("httpcore-osgi").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("com.xmlcalabash").versionAsInProject(),
			mavenBundle().groupId("org.eclipse.persistence").artifactId("javax.persistence").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("common-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("xpath-registry").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("xproc-api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("framework-core").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("calabash-adapter").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("common-java").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-core").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-calabash").versionAsInProject(),
			forThisPlatform(mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-native").versionAsInProject()),
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("css-core").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("css-calabash").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("css-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("brailleutils-core").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("brailleutils-catalog").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("pef-calabash").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("pef-saxon").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("pef-to-html").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("pef-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("common-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("file-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("common-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("html-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("zip-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("mediatype-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("fileset-utils").versionAsInProject(),
			mavenBundle().groupId("org.codehaus.woodstox").artifactId("woodstox-core-lgpl").versionAsInProject(),
			mavenBundle().groupId("org.codehaus.woodstox").artifactId("stax2-api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("woodstox-osgi-adapter").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("xmlcatalog").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("modules-registry").versionAsInProject(),
			mavenBundle().groupId("org.daisy.maven").artifactId("xproc-engine-api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.maven").artifactId("xproc-engine-daisy-pipeline").versionAsInProject(),
			wrappedBundle(mavenBundle().groupId("org.daisy.xprocspec").artifactId("xprocspec").version("1.1.0"))
				.bundleSymbolicName("org.daisy.xprocspec")
				.bundleVersion("1.1.0"),
			mavenBundle().groupId("org.daisy.maven").artifactId("xprocspec-runner").versionAsInProject(),
			mavenBundle().groupId("commons-io").artifactId("commons-io").versionAsInProject(),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/classes/"),
			junitBundles()
		);
	}
	
	@Test
	public void runXProcSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		boolean success = runner.run(new File(baseDir, "src/test/xprocspec"),
		                             new File(baseDir, "target/xprocspec-reports"),
		                             new File(baseDir, "target/surefire-reports"),
		                             new File(baseDir, "target/xprocspec"),
		                             new XProcSpecRunner.Reporter.DefaultReporter());
		assertTrue("XProcSpec tests should run with success", success);
	}
	
	public static MavenArtifactProvisionOption forThisPlatform(MavenArtifactProvisionOption bundle) {
		String name = System.getProperty("os.name").toLowerCase();
		if (name.startsWith("windows"))
			return bundle.classifier("windows");
		else if (name.startsWith("mac os x"))
			return bundle.classifier("mac");
		else if (name.startsWith("linux"))
			return bundle.classifier("linux");
		else
			throw new RuntimeException("Unsupported OS: " + name);
	}
}
