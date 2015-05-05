import java.io.File;
import java.io.InputStream;
import java.io.IOException;
import java.net.URL;
import java.util.NoSuchElementException;
import java.util.Properties;
import javax.inject.Inject;

import static org.daisy.pipeline.braille.common.util.URLs.asURL;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.bundlesAndDependencies;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.forThisPlatform;
import static org.daisy.pipeline.pax.exam.Options.logbackBundles;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;

import static org.junit.Assert.assertNotNull;
import org.junit.Test;
import org.junit.runner.RunWith;

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
public class LiblouisTablesTest {
	
	@Inject
	LiblouisTranslator.Provider provider;
	
	@Test
	public void testCompileAllTablesInManifest() throws IOException {
		URL manifest = asURL(new File(new File(PathUtils.getBaseDir()), "target/classes/manifest.xml"));
		manifest.openConnection();
		InputStream reader = manifest.openStream();
		Properties properties = new Properties();
		properties.loadFromXML(reader);
		for (String key : properties.stringPropertyNames()) {
			String table = properties.getProperty(key);
			assertNotEmpty("Table " + table + " does not compile", provider.get("(table:'" + table + "')")); }
		reader.close();
	}
	
	private void assertNotEmpty(String message, Iterable<?> iterable) {
		try {
			iterable.iterator().next(); }
		catch (NoSuchElementException e) {
			throw new AssertionError(message); }
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
			mavenBundle().groupId("org.daisy.bindings").artifactId("jhyphen").versionAsInProject(),
			mavenBundle().groupId("org.apache.servicemix.bundles").artifactId("org.apache.servicemix.bundles.antlr-runtime").versionAsInProject(),
			mavenBundle().groupId("org.daisy.libs").artifactId("jstyleparser").versionAsInProject(),
			bundlesAndDependencies("org.daisy.pipeline.calabash-adapter"),
			brailleModule("common-utils"),
			brailleModule("css-core"),
			brailleModule("liblouis-core"),
			forThisPlatform(brailleModule("liblouis-native")),
			brailleModule("libhyphen-core"),
			thisBundle(),
			junitBundles()
		);
	}
}
