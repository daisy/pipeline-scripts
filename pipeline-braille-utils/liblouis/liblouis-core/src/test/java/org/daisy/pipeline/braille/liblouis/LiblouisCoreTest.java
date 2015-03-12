package org.daisy.pipeline.braille.liblouis;

import javax.inject.Inject;

import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator.Typeform;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.bundlesAndDependencies;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
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
import static org.ops4j.pax.exam.CoreOptions.systemProperty;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class LiblouisCoreTest {
	
	@Inject
	LiblouisTranslator.Provider provider;
	
	@Inject
	LiblouisHyphenator.Provider hyphenatorProvider;
	
	@Inject
	LiblouisTableResolver resolver;
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			domTraversalPackage(),
			logbackBundles(),
			felixDeclarativeServices(),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			bundlesAndDependencies("org.daisy.pipeline.calabash-adapter"),
			brailleModule("common-utils"),
			brailleModule("css-core"),
			// depends on https://github.com/liblouis/liblouis/pull/41
			systemProperty("org.daisy.pipeline.liblouis.external").value("true"),
			// forThisPlatform(brailleModule("liblouis-native")),
			thisBundle("org.daisy.pipeline.modules.braille", "liblouis-core"),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/test-classes/table_paths/"),
			junitBundles()
		);
	}
	
	@Test
	public void testResolveTableFile() {
		assertEquals("foobar.cti", asFile(resolver.resolve(asURI("foobar.cti"))).getName());
	}
	
	@Test
	public void testResolveTable() {
		assertEquals("foobar.cti", (resolver.resolveLiblouisTable(new LiblouisTable("foobar.cti"), null)[0]).getName());
	}
	
	@Test
	public void testGetTranslatorFromQuery1() {
		provider.get("(locale:foo)").iterator().next();
	}
	
	@Test
	public void testGetTranslatorFromQuery2() {
		provider.get("(table:'foobar.cti')").iterator().next();
	}
	
	@Test
	public void testGetTranslatorFromQuery3() {
		provider.get("(locale:foo_BAR)").iterator().next();
	}
	
	@Test
	public void testTranslate() {
		assertEquals("foobar", provider.get("(table:'foobar.cti')").iterator().next().transform("foobar"));
	}
	
	@Test
	public void testTranslateStyled() {
		assertEquals("foobar", provider.get("(table:'foobar.cti')").iterator().next().transform("foobar", Typeform.ITALIC));
	}
	
	@Test
	public void testTranslateSegments() {
		LiblouisTranslator translator = provider.get("(table:'foobar.cti')").iterator().next();
		assertEquals(new String[]{"foo","bar"}, translator.transform(new String[]{"foo","bar"}));
		assertEquals(new String[]{"foo","","bar"}, translator.transform(new String[]{"foo","","bar"}));
	}
	
	@Test
	public void testTranslateSegmentsFuzzy() {
		LiblouisTranslator translator = provider.get("(table:'foobar.ctb')").iterator().next();
		assertEquals(new String[]{"fu","bar"}, translator.transform(new String[]{"foo","bar"}));
		assertEquals(new String[]{"fu","bar"}, translator.transform(new String[]{"fo","obar"}));
		assertEquals(new String[]{"fu","","bar"}, translator.transform(new String[]{"fo","","obar"}));
		assertEquals(new String[]{"x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ",
		                          "x ", "x ", "x ", "x ", "fu", "bar"},
		             translator.transform(new String[]{
		                          "x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ",
		                          "x ", "x ", "x ", "x ", "fo", "obar"}));

	}
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar", (hyphenatorProvider.get("(table:'foobar.cti,foobar.dic')").iterator().next()).transform("foobar"));
	}
	
	@Test
	public void testHyphenateCompoundWord() {
		assertEquals("foo-\u200Bbar", (hyphenatorProvider.get("(table:'foobar.cti,foobar.dic')").iterator().next()).transform("foo-bar"));
	}
	
	@Test
	public void testTranslateAndHyphenateSomeSegments() {
		LiblouisTranslator translator = provider.get("(table:'foobar.cti,foobar.dic')").iterator().next();
		assertEquals(new String[]{"foo\u00ADbar ","foobar"},
		             translator.transform(new String[]{"foobar ","foobar"}, new String[]{"hyphens:auto","hyphens:none"}));
	}
}
