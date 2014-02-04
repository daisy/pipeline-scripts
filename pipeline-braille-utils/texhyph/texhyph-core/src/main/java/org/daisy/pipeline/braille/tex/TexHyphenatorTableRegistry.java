package org.daisy.pipeline.braille.tex;

import java.net.URI;
import java.util.Locale;

import org.daisy.pipeline.braille.ResourceLookup;
import org.daisy.pipeline.braille.ResourceRegistry;

public class TexHyphenatorTableRegistry extends ResourceRegistry<TexHyphenatorTablePath>
	                                    implements TexHyphenatorTableLookup, TexHyphenatorTableResolver {
	
	@Override
	protected void register(TexHyphenatorTablePath path) {
		super.register(path);
		cachedLookup.invalidateCache();
	}
	
	@Override
	protected void unregister (TexHyphenatorTablePath path) {
		super.unregister(path);
		cachedLookup.invalidateCache();
	}
	
	/**
	 * Try to find a table based on the given locale.
	 * An automatic fallback mechanism is used: if nothing is found for
	 * language-COUNTRY-variant, then language-COUNTRY is searched, then language.
	 */
	public URI lookup(Locale locale) {
		return cachedLookup.lookup(locale);
	}
	
	private final DispatchingLookup<Locale,URI> dispatchingLookup = new DispatchingLookup<Locale,URI>() {
		public Iterable<? extends ResourceLookup<Locale,URI>> dispatch() {
			return paths.values();
		}
	};
	
	private final ResourceLookup<Locale,URI> lookup = LocaleBasedLookup.<URI>newInstance(dispatchingLookup);
	private final CachedLookup<Locale,URI> cachedLookup = CachedLookup.<Locale,URI>newInstance(lookup);
	
}
