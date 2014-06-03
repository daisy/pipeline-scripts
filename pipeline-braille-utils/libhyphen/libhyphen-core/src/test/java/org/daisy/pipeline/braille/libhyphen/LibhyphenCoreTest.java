package org.daisy.pipeline.braille.libhyphen;

import javax.inject.Inject;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.options.MavenArtifactProvisionOption;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.daisy.pipeline.braille.Utilities.URIs.asURI;

import static org.ops4j.pax.exam.CoreOptions.bundle;
import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;
import static org.ops4j.pax.exam.CoreOptions.systemProperty;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class LibhyphenCoreTest {
	
	@Inject
	Libhyphen libhyphen;
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar", libhyphen.hyphenate(asURI("foobar.dic"), "foobar"));
		assertEquals("foo-\u200Bbar", libhyphen.hyphenate(asURI("foobar.dic"), "foo-bar"));
	}
	
	@Configuration
	public Option[] config() {
		return options(
			systemProperty("logback.configurationFile").value("file:" + PathUtils.getBaseDir() + "/src/test/resources/logback.xml"),
			mavenBundle().groupId("org.slf4j").artifactId("slf4j-api").version("1.7.2"),
			mavenBundle().groupId("ch.qos.logback").artifactId("logback-core").version("1.0.11"),
			mavenBundle().groupId("ch.qos.logback").artifactId("logback-classic").version("1.0.11"),
			mavenBundle().groupId("org.apache.felix").artifactId("org.apache.felix.scr").version("1.6.2"),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.daisy.bindings").artifactId("jhyphen").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("common-java").versionAsInProject(),
			forThisPlatform(mavenBundle().groupId("org.daisy.pipeline.modules.braille").artifactId("libhyphen-native").versionAsInProject()),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/classes/"),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/test-classes/table_paths/"),
			junitBundles()
		);
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
