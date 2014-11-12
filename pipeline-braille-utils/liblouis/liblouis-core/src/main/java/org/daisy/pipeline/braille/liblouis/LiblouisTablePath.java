package org.daisy.pipeline.braille.liblouis;

import java.net.URI;
import java.net.URL;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;

import org.daisy.pipeline.braille.common.BundledResourcePath;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.Strings.join;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import org.osgi.service.component.ComponentContext;

public class LiblouisTablePath extends BundledResourcePath implements LiblouisTableProvider {
	
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
	
	private Provider<Locale,URI[]> provider = new Provider.NULL<Locale,URI[]>();
	
	public Iterable<URI[]> get(Locale locale) {
		return provider.get(locale);
	}
	
	private void initLocaleBasedProvider(URL manifestURL) {
		provider = new SimpleMappingProvider<Locale,URI[]>(manifestURL) {
			public Locale parseKey(String locale) {
				return parseLocale(locale);
			}
			public URI[] parseValue(String tableList) {
				URI[] tokenized = tokenizeTableList(tableList);
				for (int i = 0; i < tokenized.length; i++) {
					URI canonical = canonicalize(tokenized[i]);
					if (canonical != null)
						tokenized[i] = canonical; }
				return tokenized;
			}
		};
	}
	
	public static URI[] tokenizeTableList(String tableList) {
		return Iterables.toArray(
			Iterables.<String,URI>transform(
				Splitter.on(',').split(tableList),
				asURI),
			URI.class);
	}
	
	public static String serializeTableList(URI[] tableList) {
		return join(tableList, ",");
	}
}
