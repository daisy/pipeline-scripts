package org.daisy.pipeline.braille.liblouis;

import javax.inject.Inject;

import static org.daisy.pipeline.braille.liblouis.LetterSpacingHandler.letterSpacingFromInlineCSS;
import static org.daisy.pipeline.braille.liblouis.LetterSpacingHandler.textFromLetterSpacing;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.bundlesAndDependencies;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;

import static org.junit.Assert.assertEquals;
import org.junit.Ignore;
import org.junit.runner.RunWith;
import org.junit.Test;

import org.liblouis.Translator;

import static org.ops4j.pax.exam.CoreOptions.bundle;
import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import org.osgi.framework.BundleContext;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class LetterSpacingHandlerTest {
	
	@Inject
	private BundleContext context;
	
	@Ignore @Test
	public void testLetterSpacingFromCSS() {
		assertEquals(1, letterSpacingFromInlineCSS("letter-spacing: 1;"));
		assertEquals(2, letterSpacingFromInlineCSS("letter-spacing: 2;"));
	}
	
	//TODO: Handle numbers according to Finnish braille specification
	@Test
	public void testTextFromLetterSpacing() {
		assertEquals(
			"f o o   b a r",
			textFromLetterSpacing("foo bar", 1));
		assertEquals(
			"f  o  o     b  a  r",
			textFromLetterSpacing("foo bar", 2));
	}
	
	@Test
	public void testTranslateWithLetterSpacing() {
		LetterSpacingHandler handler = new LetterSpacingHandler("(table:'foobar.cti')", context);
		assertEquals(
			"f o o b a r",
			handler.translateWithSpacing("foobar", 1));
		assertEquals(
			"f  o  o  b  a  r",
			handler.translateWithSpacing("foobar", 2));
	}
	
	@Ignore @Test
	public void testTranslateWithLetterSpacingAndPunctuations() {
		LetterSpacingHandler handler = new LetterSpacingHandler("(table:'foobar.cti')", context);
		assertEquals(
			"f o o b a r.",
			handler.translateWithSpacing("foobar.", 1));
		assertEquals(
			"f  o  o  b  a  r.",
			handler.translateWithSpacing("foobar.", 2));
	}
	
	@Ignore @Test
	public void testTranslateWithLetterSpacingAndContractions() {
		LetterSpacingHandler handler = new LetterSpacingHandler("(table:'foobar.ctb')", context);
		assertEquals(
			"fu b a r",
			handler.translateWithSpacing("foobar", 1));
		assertEquals(
			"fu  b  a  r",
			handler.translateWithSpacing("foobar", 2));
	}
	
	@Ignore @Test
	public void testTranslateWithWordSpacing() {
		LetterSpacingHandler handler = new LetterSpacingHandler("(table:'foobar.cti')", context);
		assertEquals(
			"foo  bar",
			handler.translateWithSpacing("foo bar", 0, 2));
		assertEquals(
			"foo   bar",
			handler.translateWithSpacing("foo bar", 0, 3));
	}
	
	@Ignore @Test
	public void testTranslateWithLetterSpacingAndWordSpacing() {
		LetterSpacingHandler handler = new LetterSpacingHandler("(table:'foobar.cti')", context);
		assertEquals(
			"f o o  b a r",
			handler.translateWithSpacing("foo bar", 1, 2));
		assertEquals(
			"f o o   b a r",
			handler.translateWithSpacing("foo bar", 1, 3));
		assertEquals(
			"f  o  o    b  a  r",
			handler.translateWithSpacing("foo bar", 2, 4));
		assertEquals(
			"f  o  o     b  a  r",
			handler.translateWithSpacing("foo bar", 2, 5));
	}
	
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
			mavenBundle().groupId("org.unbescape").artifactId("unbescape").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-css").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-utils.api").versionAsInProject(),
			bundlesAndDependencies("org.daisy.pipeline.calabash-adapter"),
			brailleModule("common-utils"),
			brailleModule("css-core"),
			forThisPlatform(brailleModule("liblouis-native")),
			brailleModule("pef-core"),
			thisBundle(),
			bundle("reference:file:" + PathUtils.getBaseDir() + "/target/test-classes/table_paths/"),
			junitBundles()
		);
	}
}
