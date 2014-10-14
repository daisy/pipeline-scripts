package org.daisy.pipeline.braille.liblouis;

import java.net.URI;

import javax.inject.Inject;

import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.bundlesAndDependencies;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

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
public class LiblouisCoreTest {
	
	@Inject
	Liblouis liblouis;
	
	@Inject
	LiblouisTableResolver resolver;
	
	@Inject
	LiblouisTableProvider tableProvider;
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			logbackBundles(),
			felixDeclarativeServices(),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			bundlesAndDependencies("net.sf.saxon.saxon-he"),
			brailleModule("common-utils"),
			forThisPlatform(brailleModule("liblouis-native")),
			thisBundle(),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/test-classes/table_paths/"),
			junitBundles()
		);
	}
	
	@Test
	public void testResolveTable() {
		assertEquals("foobar.cti", asFile(resolver.resolve(asURI("foobar.cti"))).getName());
	}
	
	@Test
	public void testResolveTableList() {
		assertEquals("foobar.cti", (resolver.resolveTableList(new URI[]{asURI("foobar.cti")}, null)[0]).getName());
	}
	
	@Test
	public void testGetTableFromLocale() {
		assertEquals(new URI[]{asURI("http://test/table_path_1/foobar.cti")}, tableProvider.get(parseLocale("foo")));
		assertNull(tableProvider.get(parseLocale("bar")));
	}
	
	@Test
	public void testTranslate() {
		assertEquals("foobar", liblouis.get(new URI[]{asURI("foobar.cti")}).translate("foobar", false, null));
	}
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar", liblouis.get(new URI[]{asURI("foobar.cti"),asURI("foobar.dic")}).hyphenate("foobar"));
	}
	
	@Test
	public void testHyphenateCompoundWord() {
		assertEquals("foo-\u200Bbar", liblouis.get(new URI[]{asURI("foobar.cti"),asURI("foobar.dic")}).hyphenate("foo-bar"));
	}
}
