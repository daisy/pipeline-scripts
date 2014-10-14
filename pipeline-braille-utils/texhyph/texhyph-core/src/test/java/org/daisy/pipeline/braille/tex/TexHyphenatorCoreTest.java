package org.daisy.pipeline.braille.tex;

import javax.inject.Inject;

import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
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
public class TexHyphenatorCoreTest {
	
	@Inject
	TexHyphenatorProvider provider;
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar", provider.get(asURI("foobar.tex")).hyphenate("foobar"));
		assertEquals("foo-\u200Bbar", provider.get(asURI("foobar.tex")).hyphenate("foo-bar"));
	}
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			logbackBundles(),
			felixDeclarativeServices(),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("com.googlecode.texhyphj").artifactId("texhyphj").versionAsInProject(),
			brailleModule("common-utils"),
			thisBundle(),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/test-classes/table_paths/"),
			junitBundles()
		);
	}
}
