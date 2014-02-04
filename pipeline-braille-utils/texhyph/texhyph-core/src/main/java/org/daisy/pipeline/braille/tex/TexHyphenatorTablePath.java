package org.daisy.pipeline.braille.tex;

import java.net.URI;
import java.net.URL;
import java.util.Locale;
import java.util.Map;

import org.osgi.service.component.ComponentContext;

import org.daisy.pipeline.braille.BundledResourcePath;
import org.daisy.pipeline.braille.ResourceLookup;

import static org.daisy.pipeline.braille.Utilities.Locales.parseLocale;
import static org.daisy.pipeline.braille.Utilities.URIs.asURI;

public class TexHyphenatorTablePath extends BundledResourcePath implements TexHyphenatorTableLookup {
	
	private static final String MANIFEST = "manifest";
	
	@Override
	protected void activate(ComponentContext context, Map<?, ?> properties) throws Exception {
		if (properties.get(UNPACK) != null)
			throw new IllegalArgumentException(UNPACK + " property not supported");
		super.activate(context, properties);
		if (properties.get(MANIFEST) != null) {
			String manifestPath = properties.get(MANIFEST).toString();
			final URL manifestURL = context.getBundleContext().getBundle().getEntry(manifestPath);
			if (manifestURL == null)
				throw new IllegalArgumentException("Manifest at location " + manifestPath + " could not be found");
			initLookup(manifestURL); }
	}
	
	public URI lookup(Locale locale) {
		return lookup.lookup(locale);
	}
	
	private ResourceLookup<Locale,URI> lookup = new ResourceLookup.NULL<Locale,URI>();
	
	private void initLookup(URL manifestURL) {
		lookup = new PropertiesLookup<Locale,URI>(manifestURL) {
			public Locale parseKey(String locale) {
				return parseLocale(locale);
			}
			public URI parseValue(String table) {
				return canonicalize(asURI(table));
			}
		};
	}
}
