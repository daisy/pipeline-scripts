package org.daisy.pipeline.braille.tex;

import java.net.URI;
import java.util.Locale;

import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.ResourceRegistry;

public class TexHyphenatorTableRegistry extends ResourceRegistry<TexHyphenatorTablePath>
	                                    implements TexHyphenatorTableProvider, TexHyphenatorTableResolver {
	
	@Override
	protected void register(TexHyphenatorTablePath path) {
		super.register(path);
		provider.invalidateCache();
	}
	
	@Override
	protected void unregister (TexHyphenatorTablePath path) {
		super.unregister(path);
		provider.invalidateCache();
	}
	
	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public Iterable<URI> get(Locale locale) {
		return provider.get(locale);
	}
	
	private final CachedProvider<Locale,URI> provider
		= CachedProvider.<Locale,URI>newInstance(
			LocaleBasedProvider.<URI>newInstance(
				new DispatchingProvider<Locale,URI>() {
					public Iterable<? extends Provider<Locale,URI>> dispatch() {
						return paths.values(); }}));
	
}
