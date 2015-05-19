package org.daisy.pipeline.braille.liblouis;

import java.net.URI;
import java.net.URL;
import java.util.Locale;
import java.util.Map;

import org.daisy.pipeline.braille.common.BundledResourcePath;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;

import org.osgi.service.component.ComponentContext;

public class LiblouisTablePath extends BundledResourcePath implements Provider<Locale,LiblouisTable> {
	
	private static final String MANIFEST = "manifest";
	
	@Override
	protected void activate(ComponentContext context, Map<?,?> properties) throws Exception {
		if (properties.get(UNPACK) != null)
			throw new IllegalArgumentException(UNPACK + " property not supported");
		super.activate(context, properties);
		lazyUnpack(context);
		if (properties.get(MANIFEST) != null) {
			String manifestPath = properties.get(MANIFEST).toString();
			URL manifestURL = context.getBundleContext().getBundle().getEntry(manifestPath);
			if (manifestURL == null)
				throw new IllegalArgumentException("Manifest at location " + manifestPath + " could not be found");
			initLocaleBasedProvider(manifestURL); }
	}
	
	private Provider<Locale,LiblouisTable> provider = new Provider.NULL<Locale,LiblouisTable>();
	
	public Iterable<LiblouisTable> get(Locale locale) {
		return provider.get(locale);
	}
	
	private void initLocaleBasedProvider(URL manifestURL) {
		provider = new SimpleMappingProvider<Locale,LiblouisTable>(manifestURL) {
			public Locale parseKey(String locale) {
				return parseLocale(locale);
			}
			public LiblouisTable parseValue(String tableList) {
				URI[] tokenized = LiblouisTable.tokenizeTableList(tableList);
				for (int i = 0; i < tokenized.length; i++) {
					URI canonical = canonicalize(tokenized[i]);
					if (canonical != null)
						tokenized[i] = canonical; }
				return new LiblouisTable(tokenized);
			}
		};
	}
}
