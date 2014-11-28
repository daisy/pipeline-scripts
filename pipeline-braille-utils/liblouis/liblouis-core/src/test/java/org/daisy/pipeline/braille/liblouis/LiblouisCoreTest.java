package org.daisy.pipeline.braille.liblouis;

import java.net.URI;
import javax.inject.Inject;

import com.google.common.collect.Iterables;

import org.daisy.pipeline.braille.common.Hyphenator;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
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
			forThisPlatform(brailleModule("liblouis-native")),
			thisBundle(true),
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
		assertEquals(new URI[]{asURI("http://test/table_path_1/foobar.cti")}, tableProvider.get(parseLocale("foo")).iterator().next());
		assertNull(Iterables.<URI[]>getFirst(tableProvider.get(parseLocale("bar")), null));
	}
	
	@Test
	public void testGetTranslatorFromQuery1() {
		liblouis.get("(locale:foo)").iterator().next();
	}
	
	@Test
	public void testGetTranslatorFromQuery2() {
		liblouis.get("(table:'foobar.cti')").iterator().next();
	}
	
	@Test
	public void testTranslate() {
		assertEquals("foobar", liblouis.get("(table:'foobar.cti')").iterator().next().transform("foobar"));
	}
	
	@Test
	public void testTranslateStyled() {
		assertEquals("foobar", liblouis.get("(table:'foobar.cti')").iterator().next().transform("foobar", Typeform.ITALIC));
	}
	
	@Test
	public void testTranslateSegments() {
		LiblouisTranslator translator = liblouis.get("(table:'foobar.cti')").iterator().next();
		assertEquals(new String[]{"foo","bar"}, translator.transform(new String[]{"foo","bar"}));
		assertEquals(new String[]{"foo","","bar"}, translator.transform(new String[]{"foo","","bar"}));
	}
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar", ((Hyphenator)liblouis.get("(table:'foobar.cti,foobar.dic')").iterator().next()).hyphenate("foobar"));
	}
	
	@Test
	public void testHyphenateCompoundWord() {
		assertEquals("foo-\u200Bbar", ((Hyphenator)liblouis.get("(table:'foobar.cti,foobar.dic')").iterator().next()).hyphenate("foo-bar"));
	}
	
	@Test
	public void testTranslateAndHyphenateSomeSegments() {
		LiblouisTranslator translator = liblouis.get("(table:'foobar.cti,foobar.dic')").iterator().next();
		assertEquals(new String[]{"foo\u00ADbar ","foobar"},
		             translator.transform(new String[]{"foobar ","foobar"}, new String[]{"hyphens:auto","hyphens:none"}));
	}
}
