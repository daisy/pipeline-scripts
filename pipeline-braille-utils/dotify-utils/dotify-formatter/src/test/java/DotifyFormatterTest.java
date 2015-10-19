import java.io.File;
import java.util.Hashtable;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.inject.Inject;

import com.google.common.base.Optional;
import com.google.common.base.Splitter;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;
import org.daisy.maven.xspec.TestResults;
import org.daisy.maven.xspec.XSpecRunner;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledTextTransform;
import org.daisy.pipeline.braille.common.Transform;

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
			mavenBundle().groupId("org.slf4j").artifactId("jul-to-slf4j").versionAsInProject(),
			mavenBundle().groupId("org.daisy.pipeline").artifactId("logging-activator").versionAsInProject(),
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
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.task-api").versionAsInProject(),
			mavenBundle().groupId("org.daisy.dotify").artifactId("dotify.task.impl").versionAsInProject(),
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
		
		private final static char SHY = '\u00ad';
		private final static char ZWSP = '\u200b';
		private final static char SPACE = ' ';
		private final static char CR = '\r';
		private final static char LF = '\n';
		private final static char TAB = '\t';
		private final static char NBSP = '\u00a0';
		private final static Pattern VALID_INPUT = Pattern.compile("[ivxlcdm0-9\u2800-\u28ff" + SHY + ZWSP + SPACE + LF + CR + TAB + NBSP + "]*");
		private final static Pattern NUMBER = Pattern.compile("(?<natural>[0-9]+)|(?<roman>[ivxlcdm]+)");
		private final static String NUMSIGN = "\u283c";
		private final static String[] DIGIT_TABLE = new String[]{
			"\u281a","\u2801","\u2803","\u2809","\u2819","\u2811","\u280b","\u281b","\u2813","\u280a"};
		private final static String[] DOWNSHIFTED_DIGIT_TABLE = new String[]{
			"\u2834","\u2802","\u2806","\u2812","\u2832","\u2822","\u2816","\u2836","\u2826","\u2814"};
		private final static Splitter.MapSplitter CSS_PARSER
			= Splitter.on(';').omitEmptyStrings().withKeyValueSeparator(Splitter.on(':').limit(2).trimResults());
		
		public String transform(String text) {
			if (!VALID_INPUT.matcher(text).matches())
				throw new RuntimeException("Invalid input: \"" + text + "\"");
			return translateNumbers(text, false);
		}
		
		public String[] transform(String[] text) {
			String[] result = new String[text.length];
			for (int i = 0; i < text.length; i++)
				result[i] = transform(text[i]);
			return result;
		}
		
		public String transform(String text, String style) {
			if (!VALID_INPUT.matcher(text).matches())
				throw new RuntimeException("Invalid input: \"" + text + "\"");
			Map<String,String> parsedStyle = CSS_PARSER.split(style);
			if (parsedStyle.containsKey("text-transform") && "downshift".equals(parsedStyle.get("text-transform")))
				return translateNumbers(text, true);
			return translateNumbers(text, false);
		}
		
		public String[] transform(String[] text, String[] style) {
			String[] result = new String[text.length];
			for (int i = 0; i < text.length; i++)
				result[i] = transform(text[i], style[i]);
			return result;
		}
		
		private static String translateNumbers(String text, boolean downshift) {
			Matcher m = NUMBER.matcher(text);
			int idx = 0;
			StringBuilder sb = new StringBuilder();
			for (; m.find(); idx = m.end()) {
				sb.append(text.substring(idx, m.start()));
				String number = m.group();
				if (m.group("roman") != null)
					sb.append(translateRomanNumber(number));
				else
					sb.append(translateNaturalNumber(Integer.parseInt(number), downshift)); }
			if (idx == 0)
				return text;
			sb.append(text.substring(idx));
			return sb.toString();
		}
		
		private static String translateNaturalNumber(int number, boolean downshift) {
			StringBuilder sb = new StringBuilder();
			String[] table = downshift ? DOWNSHIFTED_DIGIT_TABLE : DIGIT_TABLE;
			if (number == 0)
				sb.append(table[0]);
			while (number > 0) {
				sb.insert(0, table[number % 10]);
				number = number / 10; }
			if (!downshift)
				sb.insert(0, NUMSIGN);
			return sb.toString();
		}
		
		private static String translateRomanNumber(String number) {
			return number.replace('i', '⠊')
			             .replace('v', '⠧')
			             .replace('x', '⠭')
			             .replace('l', '⠇')
			             .replace('c', '⠉')
			             .replace('d', '⠙')
			             .replace('m', '⠍');
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
