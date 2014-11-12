import java.io.File;
import java.net.URI;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.Map;
import javax.inject.Inject;
import javax.xml.namespace.QName;

import com.google.common.base.Optional;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;
import org.daisy.maven.xspec.TestResults;
import org.daisy.maven.xspec.XSpecRunner;

import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.TextTransform.ContextUnawareTextTransform;
import static org.daisy.pipeline.braille.common.util.Strings.extractHyphens;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.XProcTransform;

import static org.daisy.pipeline.pax.exam.Options.calabashConfigFile;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
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
import static org.ops4j.pax.exam.CoreOptions.options;

import org.osgi.framework.BundleContext;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class CommonUtilsTest {
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			calabashConfigFile(),
			logbackBundles(),
			felixDeclarativeServices(),
			thisBundle(true),
			xspecBundles(),
			xprocspecBundles(),
			junitBundles()
		);
	}
	
	@Inject
	private BundleContext context;
	
	@Before
	public void registerUppercaseTransformProvider() {
		final UppercaseTransform transform = new UppercaseTransform();
		UppercaseTransform.Provider<UppercaseTransform> provider
			= new UppercaseTransform.Provider<UppercaseTransform>() {
				public Iterable<UppercaseTransform> get(String query) {
					return Optional.<UppercaseTransform>fromNullable(
						query.equals("(uppercase)") ? transform : null).asSet(); }};
		Hashtable<String,Object> properties = new Hashtable<String,Object>();
		context.registerService(TextTransform.Provider.class.getName(), provider, properties);
		context.registerService(XProcTransform.Provider.class.getName(), provider, properties);
	}
	
	private static class UppercaseTransform extends ContextUnawareTextTransform implements XProcTransform {
		public String transform(String text) {
			return text.toUpperCase();
		}
		private final URI href = asURI(new File(new File(PathUtils.getBaseDir()), "target/test-classes/uppercase.xpl"));
		public Tuple3<URI,QName,Map<String,String>> asXProc() {
			return new Tuple3<URI,QName,Map<String,String>>(href, null, null);
		}
		public interface Provider<T extends UppercaseTransform> extends TextTransform.Provider<T>, XProcTransform.Provider<T> {}
	}
	
	@Test
	public void testExtractHyphens() throws Exception {
		assertEquals("[0, 0, 1, 0, 0]", Arrays.toString(extractHyphens("foo\u00ADbar", '\u00AD')._2));
		assertEquals("[0, 0, 0, 2, 0, 0]", Arrays.toString(extractHyphens("foo-\u200Bbar", null, '\u200B')._2));
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
}
