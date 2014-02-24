import java.io.File;

import java.util.Collection;

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

import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemProperty;
import static org.ops4j.pax.exam.CoreOptions.wrappedBundle;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class DtbookToOdtTest {
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
	
	@Configuration
	public Option[] config() {
		return options(
			systemProperty("logback.configurationFile").value("file:" + PathUtils.getBaseDir() + "/src/test/resources/logback.xml"),
			systemProperty("org.daisy.pipeline.xproc.configuration").value(PathUtils.getBaseDir() + "/src/test/resources/config-calabash.xml"),
			mavenBundle().groupId("org.slf4j").artifactId("slf4j-api").version("1.7.2"),
			mavenBundle().groupId("ch.qos.logback").artifactId("logback-core").version("1.0.11"),
			mavenBundle().groupId("ch.qos.logback").artifactId("logback-classic").version("1.0.11"),
			mavenBundle().groupId("org.apache.felix").artifactId("org.apache.felix.scr").version("1.6.2"),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("saxon-he").versionAsInProject(),
			mavenBundle().groupId("org.slf4j").artifactId("jcl-over-slf4j").versionAsInProject(),
			mavenBundle().groupId("commons-codec").artifactId("commons-codec").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("commons-httpclient").versionAsInProject(),
			mavenBundle().groupId("nu.validator.htmlparser").artifactId("htmlparser").versionAsInProject(),
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
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("file-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("common-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("html-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("zip-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("mediatype-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("fileset-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("validation-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("dtbook-validator").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("dtbook-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("image-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("asciimath-utils").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules").artifactId("odt-utils").versionAsInProject(),
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
