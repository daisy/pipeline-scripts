package org.daisy.pipeline.braille.liblouis;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.NoSuchElementException;

import javax.inject.Inject;

import org.daisy.braille.api.table.BrailleConverter;
import org.daisy.braille.api.table.Table;
import org.daisy.braille.api.table.TableCatalogService;

import org.daisy.pipeline.braille.common.BrailleTranslator.CSSStyledText;
import org.daisy.pipeline.braille.common.BrailleTranslator.FromStyledTextToBraille;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import org.daisy.pipeline.braille.common.Query;
import static org.daisy.pipeline.braille.common.Query.util.query;
import static org.daisy.pipeline.braille.common.util.Files.asFile;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import org.daisy.pipeline.braille.liblouis.LiblouisTranslator.Typeform;
import org.daisy.pipeline.braille.pef.TableProvider;

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

import static org.junit.Assert.assertArrayEquals;
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

import org.osgi.framework.BundleContext;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.framework.ServiceReference;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class LiblouisCoreTest {
	
	@Inject
	LiblouisTranslator.Provider provider;
	
	@Inject
	LiblouisHyphenator.Provider hyphenatorProvider;
	
	@Inject
	LiblouisTableResolver resolver;
	
	@Inject
	private TableCatalogService tableCatalog;
	
	private static final Logger messageBus = LoggerFactory.getLogger("JOB_MESSAGES");
	
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
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.api").versionAsInProject(),
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
		provider.withContext(messageBus).get(query("(locale:foo)")).iterator().next();
	}
	
	@Test
	public void testGetTranslatorFromQuery2() {
		provider.withContext(messageBus).get(query("(table:'foobar.cti')")).iterator().next();
	}
	
	@Test
	public void testGetTranslatorFromQuery3() {
		provider.withContext(messageBus).get(query("(locale:foo_BAR)")).iterator().next();
	}
	
	@Test(expected=NoSuchElementException.class)
	public void testGetTranslatorFromQuery4() {
		provider.withContext(messageBus).get(query("(locale:bar)")).iterator().next();
	}
	
	@Test
	public void testTranslate() {
		assertEquals(braille("⠋⠕⠕⠃⠁⠗"),
		             provider.withContext(messageBus)
		                     .get(query("(table:'foobar.cti')")).iterator().next()
		                     .fromStyledTextToBraille().transform(styledText("foobar","")));
	}
	
	@Test
	public void testTranslateStyled() {
		assertArrayEquals(new String[]{"⠋⠕⠕⠃⠁⠗"},
		                  provider.withContext(messageBus)
		                          .get(query("(table:'foobar.cti')")).iterator().next()
		                          .fromTypeformedTextToBraille().transform(new String[]{"foobar"}, new byte[]{Typeform.ITALIC}));
	}
	
	@Test
	public void testTranslateSegments() {
		FromStyledTextToBraille translator = provider.withContext(messageBus)
		                                             .get(query("(table:'foobar.cti')")).iterator().next()
		                                             .fromStyledTextToBraille();
		assertEquals(braille("⠋⠕⠕","⠃⠁⠗"),
		             translator.transform(styledText("foo","",
		                                             "bar","")));
		assertEquals(braille("⠋⠕⠕","","⠃⠁⠗"),
		             translator.transform(styledText("foo","",
		                                             "",   "",
		                                             "bar","")));
	}
	
	@Test
	public void testTranslateSegmentsFuzzy() {
		FromStyledTextToBraille translator = provider.withContext(messageBus)
		                                             .get(query("(table:'foobar.ctb')")).iterator().next()
		                                             .fromStyledTextToBraille();
		assertEquals(braille("⠋⠥","⠃⠁⠗"),
		             translator.transform(styledText("foo", "",
		                                             "bar", "")));
		assertEquals(braille("⠋⠥","⠃⠁⠗"),
		             translator.transform(styledText("fo",   "",
		                                             "obar", "")));
		assertEquals(braille("⠋⠥\u00AD","⠃⠁⠗"),
		             translator.transform(styledText("fo",         "",
		                                             "o\u00ADbar", "")));
		assertEquals(braille("⠋⠥","","⠃⠁⠗"),
		             translator.transform(styledText("fo",   "",
		                                             "",     "",
		                                             "obar", "")));
		assertEquals(braille("⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠋⠥", "⠃⠁⠗"),
		             translator.transform(styledText("x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "x ",   "",
		                                             "fo",   "",
		                                             "obar", "")));
	}
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar",
		             hyphenatorProvider.withContext(messageBus)
		                 .get(query("(table:'foobar.cti,foobar.dic')")).iterator().next()
		                 .transform(new String[]{"foobar"})[0]);
	}
	
	@Test
	public void testHyphenateCompoundWord() {
		assertEquals("foo-\u200Bbar",
		             hyphenatorProvider.withContext(messageBus)
		                 .get(query("(table:'foobar.cti,foobar.dic')")).iterator().next()
		                 .transform(new String[]{"foo-bar"})[0]);
	}
	
	@Test
	public void testTranslateAndHyphenateSomeSegments() {
		FromStyledTextToBraille translator = provider.withContext(messageBus)
		                                             .get(query("(table:'foobar.cti,foobar.dic')")).iterator().next()
		                                             .fromStyledTextToBraille();
		assertEquals(braille("⠋⠕⠕\u00AD⠃⠁⠗ ","⠋⠕⠕⠃⠁⠗"),
		             translator.transform(styledText("foobar ", "hyphens:auto",
		                                                  "foobar",  "hyphens:none")));
	}
	
	@Test
	public void testWhiteSpaceProcessing() {
		FromStyledTextToBraille translator = provider.withContext(messageBus)
		                                             .get(query("(table:'foobar.cti')")).iterator().next()
		                                             .fromStyledTextToBraille();
		assertEquals(braille("⠋⠕⠕    ⠃⠁⠗ ⠃⠁⠵"),
		             translator.transform(styledText("foo    bar\nbaz", "")));
		assertEquals(braille("⠋⠕⠕    ⠃⠁⠗\n⠃⠁⠵"),
		             translator.transform(styledText("foo    bar\nbaz", "white-space:pre-wrap")));
		assertEquals(braille("","⠋⠕⠕    ⠃⠁⠗\n\u00AD","","⠃⠁⠵"),
		             translator.transform(styledText("",             "",
		                                             "foo    bar\n", "white-space:pre-wrap",
		                                             "\u00AD",       "",
		                                             "baz",          "")));
		assertEquals(braille("\n"),
		             translator.transform(styledText("\n", "white-space:pre-line")));
	}
	
	@Test
	public void testWhiteSpaceLost() {
		FromStyledTextToBraille translator = provider.withContext(messageBus)
		                                             .get(query("(table:'delete-ws.utb')")).iterator().next()
		                                             .fromStyledTextToBraille();
		assertEquals(braille("","⠋⠕⠕⠃⠁⠗\u00AD","","⠃⠁⠵"),
		             translator.transform(styledText("",             "",
		                                             "foo    bar\n", "white-space:pre-wrap",
		                                             "\u00AD",       "",
		                                             "baz",          "")));
	}
	
	@Test
	public void testDisplayTableProvider() {
		Iterable<TableProvider> tableProviders = getServices(TableProvider.class);
		Provider<Query,Table> tableProvider = dispatch(tableProviders);
		
		// (liblouis-table: ...)
		Table table = tableProvider.get(query("(liblouis-table:'foobar.dis')")).iterator().next();
		BrailleConverter converter = table.newBrailleConverter();
		assertEquals("⠋⠕⠕⠀⠃⠁⠗", converter.toBraille("foo bar"));
		assertEquals("foo bar", converter.toText("⠋⠕⠕⠀⠃⠁⠗"));
		
		//  (locale: ...)
		table = tableProvider.get(query("(locale:foo)")).iterator().next();
		converter = table.newBrailleConverter();
		assertEquals("⠋⠕⠕⠀⠃⠁⠗", converter.toBraille("foo bar"));
		assertEquals("foo bar", converter.toText("⠋⠕⠕⠀⠃⠁⠗"));
		
		// (id: ...)
		String id = table.getIdentifier();
		assertEquals(table, tableProvider.get(query("(id:'" + id + "')")).iterator().next());
		assertEquals(table, tableCatalog.newTable(id));
	}
	
	private Iterable<CSSStyledText> styledText(String... textAndStyle) {
		List<CSSStyledText> styledText = new ArrayList<CSSStyledText>();
		String text = null;
		boolean textSet = false;
		for (String s : textAndStyle) {
			if (textSet)
				styledText.add(new CSSStyledText(text, s));
			else
				text = s;
			textSet = !textSet; }
		if (textSet)
			throw new RuntimeException();
		return styledText;
	}
	
	private Iterable<String> braille(String... text) {
		return Arrays.asList(text);
	}
	
	@Inject
	private BundleContext context;
	
	private <S> Iterable<S> getServices(Class<S> serviceClass) {
		List<S> services = new ArrayList<S>();
		try {
			for (ServiceReference<? extends S> ref : context.getServiceReferences(serviceClass, null))
				services.add(context.getService(ref)); }
		catch (InvalidSyntaxException e) {
			throw new RuntimeException(e); }
		return services;
	}
}
