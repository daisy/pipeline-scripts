import java.io.File;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import javax.inject.Inject;

import org.apache.commons.io.FileUtils;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;
import org.daisy.maven.xproc.xprocspec.XProcSpecRunner.TestLogger;
import org.daisy.maven.xproc.xprocspec.XProcSpecRunner.TestResult;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
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
public class XmlToPefTest {
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
	
	@Configuration
	public Option[] config() {
		return options(
			systemProperty("logback.configurationFile").value("file:" + PathUtils.getBaseDir() + "/src/test/resources/logback.xml"),
			systemProperty("org.daisy.pipeline.xproc.configuration").value(PathUtils.getBaseDir() + "/src/test/resources/config-calabash.xml"),
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
			mavenBundle().groupId("org.daisy.libs").artifactId("commons-httpclient").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("com.xmlcalabash").versionAsInProject(),
			mavenBundle().groupId("org.eclipse.persistence").artifactId("javax.persistence").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("common-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("xpath-registry").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("xproc-api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("common-stax").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("framework-core").versionAsInProject(),
			mavenBundle().groupId("org.codehaus.woodstox").artifactId("woodstox-core-lgpl").versionAsInProject(),
			mavenBundle().groupId("org.codehaus.woodstox").artifactId("stax2-api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("woodstox-osgi-adapter").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("xmlcatalog").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("modules-api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("modules-registry").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("calabash-adapter").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("common-java").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-core").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-saxon").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-calabash").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-formatter").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-mathml").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("liblouis-tables").versionAsInProject(),
			mavenBundle().groupId("org.daisy.bindings").artifactId("jhyphen").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("libhyphen-core").versionAsInProject(),
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
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("fileset-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.maven").artifactId("xproc-engine-api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.maven").artifactId("xproc-engine-daisy-pipeline").versionAsInProject(),
			wrappedBundle(mavenBundle().groupId("org.daisy").artifactId("xprocspec").version("1.0.0-SNAPSHOT"))
				.bundleSymbolicName("org.daisy.xprocspec")
				.bundleVersion("1.0.0.SNAPSHOT"),
			mavenBundle().groupId("org.daisy.maven").artifactId("xprocspec-runner").versionAsInProject(),
			mavenBundle().groupId("commons-io").artifactId("commons-io").versionAsInProject(),
			junitBundles()
		);
	}
	
	@Test
	public void runXProcSpec() throws Exception {
		File testsDir = new File(PathUtils.getBaseDir() + "/src/test/xprocspec");
		File reportsDir = new File(PathUtils.getBaseDir() + "/target/xprocspec-reports");
		File surefireReportsDir = new File(PathUtils.getBaseDir() + "/target/surefire-reports");
		File tempDir = new File(PathUtils.getBaseDir() + "/target/xprocspec");
		Collection<File> testFiles = FileUtils.listFiles(testsDir, new String[]{"xprocspec"}, true);
		String[] tests = new String[testFiles.size()];
		int i = 0;
		for (File file : testFiles)
			tests[i++] = file.getAbsolutePath().substring(testsDir.getAbsolutePath().length() + 1);
		TestLogger testLogger = new TestLogger() {
			public void info(String message) { System.out.println("[INFO] " + message); }
			public void warn(String message) { System.out.println("[WARNING] " + message); }
			public void error(String message) { System.out.println("[ERROR] " + message); }
			public void debug(String message) { System.out.println("[DEBUG] " + message); }
		};
		TestResult[] results = xprocspecRunner.run(testsDir,
		                                           tests,
		                                           reportsDir,
		                                           surefireReportsDir,
		                                           tempDir,
		                                           testLogger);
		int failures = 0;
		int errors = 0;
		for (TestResult result : results) {
			switch (result.state) {
			case FAILURE:
				failures++;
				break;
			case ERROR:
				errors++;
				break;
			}
		}
		assertEquals("Number of failures and errors should be zero", 0L, failures + errors);
	}
}
