package org.daisy.pipeline.braille.liblouis;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

import javax.inject.Inject;

import org.daisy.braille.api.table.BrailleConverter;
import org.daisy.braille.api.table.Table;
import org.daisy.braille.api.table.TableCatalogService;

import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
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
		provider.withContext(messageBus).get("(locale:foo)").iterator().next();
	}
	
	@Test
	public void testGetTranslatorFromQuery2() {
		provider.withContext(messageBus).get("(table:'foobar.cti')").iterator().next();
	}
	
	@Test
	public void testGetTranslatorFromQuery3() {
		provider.withContext(messageBus).get("(locale:foo_BAR)").iterator().next();
	}
	
	@Test(expected=NoSuchElementException.class)
	public void testGetTranslatorFromQuery4() {
		provider.withContext(messageBus).get("(locale:bar)").iterator().next();
	}
	
	@Test
	public void testTranslate() {
		assertEquals("⠋⠕⠕⠃⠁⠗", provider.withContext(messageBus).get("(table:'foobar.cti')").iterator().next().transform("foobar"));
	}
	
	@Test
	public void testTranslateStyled() {
		assertEquals("⠋⠕⠕⠃⠁⠗", provider.withContext(messageBus).get("(table:'foobar.cti')").iterator().next().transform("foobar", Typeform.ITALIC));
	}
	
	@Test
	public void testTranslateSegments() {
		LiblouisTranslator translator = provider.withContext(messageBus).get("(table:'foobar.cti')").iterator().next();
		assertArrayEquals(new String[]{"⠋⠕⠕","⠃⠁⠗"}, translator.transform(new String[]{"foo","bar"}));
		assertArrayEquals(new String[]{"⠋⠕⠕","","⠃⠁⠗"}, translator.transform(new String[]{"foo","","bar"}));
	}
	
	@Test
	public void testTranslateSegmentsFuzzy() {
		LiblouisTranslator translator = provider.withContext(messageBus).get("(table:'foobar.ctb')").iterator().next();
		assertArrayEquals(new String[]{"⠋⠥","⠃⠁⠗"}, translator.transform(new String[]{"foo","bar"}));
		assertArrayEquals(new String[]{"⠋⠥","⠃⠁⠗"}, translator.transform(new String[]{"fo","obar"}));
		assertArrayEquals(new String[]{"⠋⠥\u00AD","⠃⠁⠗"}, translator.transform(new String[]{"fo","o\u00ADbar"}));
		assertArrayEquals(new String[]{"⠋⠥","","⠃⠁⠗"}, translator.transform(new String[]{"fo","","obar"}));
		assertArrayEquals(new String[]{"⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠭ ",
		                          "⠭ ", "⠭ ", "⠭ ", "⠭ ", "⠋⠥", "⠃⠁⠗"},
		             translator.transform(new String[]{
		                          "x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ", "x ",
		                          "x ", "x ", "x ", "x ", "fo", "obar"}));
	}
	
	@Test
	public void testHyphenate() {
		assertEquals("foo\u00ADbar", (hyphenatorProvider.withContext(messageBus).get("(table:'foobar.cti,foobar.dic')").iterator().next()).transform("foobar"));
	}
	
	@Test
	public void testHyphenateCompoundWord() {
		assertEquals("foo-\u200Bbar", (hyphenatorProvider.withContext(messageBus).get("(table:'foobar.cti,foobar.dic')").iterator().next()).transform("foo-bar"));
	}
	
	@Test
	public void testTranslateAndHyphenateSomeSegments() {
		LiblouisTranslator translator = provider.withContext(messageBus).get("(table:'foobar.cti,foobar.dic')").iterator().next();
		assertArrayEquals(new String[]{"⠋⠕⠕\u00AD⠃⠁⠗ ","⠋⠕⠕⠃⠁⠗"},
		             translator.transform(new String[]{"foobar ","foobar"}, new String[]{"hyphens:auto","hyphens:none"}));
	}
	
	@Test
	public void testWhiteSpaceProcessing() {
		LiblouisTranslator translator = provider.withContext(messageBus).get("(table:'foobar.cti')").iterator().next();
		assertEquals("⠋⠕⠕    ⠃⠁⠗ ⠃⠁⠵",
		             translator.transform("foo    bar\nbaz"));
		assertEquals("⠋⠕⠕    ⠃⠁⠗\n⠃⠁⠵",
		             translator.transform("foo    bar\nbaz", "white-space:pre-wrap"));
		assertArrayEquals(new String[]{"","⠋⠕⠕    ⠃⠁⠗\n\u00AD","","⠃⠁⠵"},
		             translator.transform(new String[]{"","foo    bar\n","\u00AD","baz"}, new String[]{"","white-space:pre-wrap","",""}));
		assertEquals("\n",
		             translator.transform("\n", "white-space:pre-line"));
	}
	
	@Test
	public void testWhiteSpaceLost() {
		LiblouisTranslator translator = provider.withContext(messageBus).get("(table:'delete-ws.utb')").iterator().next();
		assertArrayEquals(new String[]{"","⠋⠕⠕⠃⠁⠗\u00AD","","⠃⠁⠵"},
		             translator.transform(new String[]{"","foo    bar\n","\u00AD","baz"}, new String[]{"","white-space:pre-wrap","",""}));
	}
	
	@Test
	public void testDisplayTableProvider() {
		Iterable<TableProvider> tableProviders = getServices(TableProvider.class);
		Provider<String,Table> tableProvider = dispatch(tableProviders);
		
		// (liblouis-table: ...)
		Table table = tableProvider.get("(liblouis-table:'foobar.dis')").iterator().next();
		BrailleConverter converter = table.newBrailleConverter();
		assertEquals("⠋⠕⠕⠀⠃⠁⠗", converter.toBraille("foo bar"));
		assertEquals("foo bar", converter.toText("⠋⠕⠕⠀⠃⠁⠗"));
		
		//  (locale: ...)
		table = tableProvider.get("(locale:foo)").iterator().next();
		converter = table.newBrailleConverter();
		assertEquals("⠋⠕⠕⠀⠃⠁⠗", converter.toBraille("foo bar"));
		assertEquals("foo bar", converter.toText("⠋⠕⠕⠀⠃⠁⠗"));
		
		// (id: ...)
		String id = table.getIdentifier();
		assertEquals(table, tableProvider.get("(id:'" + id + "')").iterator().next());
		assertEquals(table, tableCatalog.newTable(id));
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
