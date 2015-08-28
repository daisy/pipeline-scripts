import java.io.File;
import java.util.Hashtable;
import java.util.Map;

import javax.inject.Inject;

import com.google.common.base.Optional;
import com.google.common.base.Splitter;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;
import org.daisy.maven.xspec.TestResults;
import org.daisy.maven.xspec.XSpecRunner;

import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledTextTransform;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.Transform.AbstractTransform;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.calabashConfigFile;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;
import static org.daisy.pipeline.pax.exam.Options.xprocspecBundles;
import static org.daisy.pipeline.pax.exam.Options.xspecBundles;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.mavenBundle;
import static org.ops4j.pax.exam.CoreOptions.options;

import org.osgi.framework.BundleContext;

import org.slf4j.Logger;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class DotifyFormatterTest {
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			calabashConfigFile(),
			domTraversalPackage(),
			logbackBundles(),
			felixDeclarativeServices(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jing").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-utils.api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-utils.pef-tools").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			mavenBundle().groupId("org.unbescape").artifactId("unbescape").versionAsInProject(),
			mavenBundle().groupId("org.daisy.braille").artifactId("braille-css").versionAsInProject(),
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.common").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.translator.impl").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.formatter.impl").versionAsInProject(),
			mavenBundle().groupId("com.google.guava").artifactId("guava").versionAsInProject(),
			mavenBundle().groupId("net.java.dev.jna").artifactId("jna").versionAsInProject(),
			mavenBundle().groupId("org.liblouis").artifactId("liblouis-java").versionAsInProject(),
			brailleModule("common-utils"),
			brailleModule("pef-core"),
			brailleModule("pef-calabash"),
			brailleModule("pef-saxon"),
			brailleModule("pef-utils"),
			pipelineModule("file-utils"),
			pipelineModule("common-utils"),
			brailleModule("obfl-utils"),
			brailleModule("css-core"),
			brailleModule("css-calabash"),
			brailleModule("css-utils"),
			brailleModule("dotify-core"),
			brailleModule("dotify-saxon"),
			brailleModule("dotify-calabash"),
			brailleModule("dotify-utils"),
			brailleModule("liblouis-core"),
			forThisPlatform(brailleModule("liblouis-native")),
			// because of bug in lou_indexTables we need to include liblouis-tables even though we're not using it
			brailleModule("liblouis-tables"),
			brailleModule("libhyphen-core"),
			mavenBundle().groupId("org.daisy.bindings").artifactId("jhyphen").versionAsInProject(),
			xspecBundles(),
			xprocspecBundles(),
			thisBundle(),
			junitBundles()
		);
	}
	
	@Inject
	private BundleContext context;
	
	@Before
	public void NumberBrailleTranslatorProvider() {
		NumberBrailleTranslator.Provider provider = new NumberBrailleTranslator.Provider();
		Hashtable<String,Object> properties = new Hashtable<String,Object>();
		context.registerService(BrailleTranslator.Provider.class.getName(), provider, properties);
		context.registerService(CSSStyledTextTransform.Provider.class.getName(), provider, properties);
	}
	
	@Inject
	private XSpecRunner xspecRunner;
	
	@Test
	public void runXSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		File testsDir = new File(baseDir, "src/test/xspec");
		File reportsDir = new File(baseDir, "target/surefire-reports");
		reportsDir.mkdirs();
		TestResults result = xspecRunner.run(testsDir, reportsDir);
		assertEquals("Number of failures and errors should be zero", 0L, result.getFailures() + result.getErrors());
	}
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
		
	@Test
	public void runXProcSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		boolean success = xprocspecRunner.run(new File(baseDir, "src/test/xprocspec"),
		                                      new File(baseDir, "target/xprocspec-reports"),
		                                      new File(baseDir, "target/surefire-reports"),
		                                      new File(baseDir, "target/xprocspec"),
		                                      new XProcSpecRunner.Reporter.DefaultReporter());
		assertTrue("XProcSpec tests should run with success", success);
	}
	
	private static class NumberBrailleTranslator extends AbstractTransform implements BrailleTranslator, CSSStyledTextTransform {
		
		private final static String NUMSIGN = "\u283c";
		private final static String[] DIGIT_TABLE = new String[]{
			"\u281a","\u2801","\u2803","\u2809","\u2819","\u2811","\u280b","\u281b","\u2813","\u280a"};
		private final static Splitter.MapSplitter CSS_PARSER
			= Splitter.on(';').omitEmptyStrings().withKeyValueSeparator(Splitter.on(':').limit(2).trimResults());
		
		private static String translateInteger(int integer) {
			StringBuilder sb = new StringBuilder();
			sb.append(NUMSIGN);
			if (integer == 0)
				sb.append(DIGIT_TABLE[0]);
			while (integer > 0) {
				sb.insert(1, DIGIT_TABLE[integer % 10]);
				integer = integer / 10; }
			return sb.toString();
		}
		
		public String transform(String text) {
			if (text.matches("[ivxlcdm]+"))
				return text.replace('i', '⠊')
				           .replace('v', '⠧')
				           .replace('x', '⠭')
				           .replace('l', '⠇')
				           .replace('c', '⠉')
				           .replace('d', '⠙')
				           .replace('m', '⠍');
			return translateInteger(Integer.parseInt(text));
		}
		
		public String[] transform(String[] text) {
			String[] result = new String[text.length];
			for (int i = 0; i < text.length; i++)
				result[i] = transform(text[i]);
			return result;
		}
		
		public String transform(String text, String style) {
			Map<String,String> parsedStyle = CSS_PARSER.split(style);
			if (parsedStyle.containsKey("text-transform") && "times-two".equals(parsedStyle.get("text-transform")))
				return translateInteger(2 * Integer.parseInt(text));
			return transform(text);
		}
		
		public String[] transform(String[] text, String[] style) {
			String[] result = new String[text.length];
			for (int i = 0; i < text.length; i++)
				result[i] = transform(text[i], style[i]);
			return result;
		}
		
		public boolean isHyphenating() { return false; }
		
		public static class Provider implements BrailleTranslator.Provider<NumberBrailleTranslator>,
		                                        CSSStyledTextTransform.Provider<NumberBrailleTranslator> {
			final static NumberBrailleTranslator instance = new NumberBrailleTranslator();
			public Iterable<NumberBrailleTranslator> get(String query) {
				return Optional.<NumberBrailleTranslator>fromNullable(
					query.equals("(number-translator)") ? instance : null).asSet();
			}
			public Transform.Provider<NumberBrailleTranslator> withContext(Logger context) {
				return this;
			}
		}
	}
}
