package org.daisy.pipeline.braille.liblouis.pef;

import javax.inject.Inject;

import java.net.URI;

import org.daisy.braille.table.BrailleConverter;

import org.daisy.pipeline.braille.liblouis.Liblouis;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;

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

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class LiblouisDisplayTableBrailleConverterTest {
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			logbackBundles(),
			felixDeclarativeServices(),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("brailleUtils-core").versionAsInProject(),
			brailleModule("common-utils"),
			brailleModule("liblouis-core"),
			forThisPlatform(brailleModule("liblouis-native")),
			thisBundle("org.daisy.pipeline.modules.braille", "liblouis-pef"),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/test-classes/table_paths/"),
			junitBundles()
		);
	}
	
	@Inject
	Liblouis liblouis;
	
	@Test
	public void testDisplayTableBrailleConverter() {
		BrailleConverter converter = new LiblouisDisplayTableBrailleConverter(liblouis.get(new URI[]{asURI("foobar.dis")}));
		assertEquals("⠋⠕⠕⠃⠁⠗", converter.toBraille("foobar"));
		assertEquals("foobar", converter.toText("⠋⠕⠕⠃⠁⠗"));
	}
}
