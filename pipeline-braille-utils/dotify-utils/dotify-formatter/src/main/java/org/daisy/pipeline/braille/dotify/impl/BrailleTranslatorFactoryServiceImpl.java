package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.regex.Matcher;

import com.google.common.collect.ImmutableList;

import org.daisy.dotify.api.translator.BrailleFilter;
import org.daisy.dotify.api.translator.BrailleTranslator;
import org.daisy.dotify.api.translator.BrailleTranslatorFactory;
import org.daisy.dotify.api.translator.BrailleTranslatorFactoryService;
import org.daisy.dotify.api.translator.BrailleTranslatorResult;
import org.daisy.dotify.api.translator.Translatable;
import org.daisy.dotify.api.translator.TranslationException;
import org.daisy.dotify.api.translator.TranslatorConfigurationException;
import org.daisy.dotify.api.translator.TranslatorSpecification;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator.util.DefaultLineBreaker;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.Query;
import static org.daisy.pipeline.braille.common.Query.util.query;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import static org.daisy.pipeline.braille.dotify.impl.BrailleFilterFactoryImpl.BRAILLE;
import static org.daisy.pipeline.braille.dotify.impl.BrailleFilterFactoryImpl.cssStyledTextFromTranslatable;
import static org.daisy.pipeline.braille.dotify.impl.BrailleFilterFactoryImpl.MODE;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.dotify.impl.BrailleTranslatorFactoryServiceImpl",
	service = { BrailleTranslatorFactoryService.class }
)
public class BrailleTranslatorFactoryServiceImpl implements BrailleTranslatorFactoryService {
	
	private BrailleFilterFactoryImpl filterFactory;
	
	@Reference(
		name = "BrailleFilterFactoryImpl",
		service = BrailleFilterFactoryImpl.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindBrailleFilterFactoryImpl(BrailleFilterFactoryImpl filterFactory) {
		this.filterFactory = filterFactory;
	}
	
	public void setCreatedWithSPI() {}
	
	@Reference(
		name = "BrailleTranslatorProvider",
		unbind = "unbindBrailleTranslatorProvider",
		service = BrailleTranslatorProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	@SuppressWarnings(
		"unchecked" // safe cast to BrailleTranslatorProvider<BrailleTranslator>
	)
	protected void bindBrailleTranslatorProvider(BrailleTranslatorProvider<?> provider) {
		brailleTranslatorProviders.add((BrailleTranslatorProvider<org.daisy.pipeline.braille.common.BrailleTranslator>)provider);
		logger.debug("Adding BrailleTranslator provider: {}", provider);
	}
	
	protected void unbindBrailleTranslatorProvider(BrailleTranslatorProvider<?> provider) {
		brailleTranslatorProviders.remove(provider);
		brailleTranslatorProvider.invalidateCache();
		logger.debug("Removing BrailleTranslator provider: {}", provider);
	}
	
	private final List<BrailleTranslatorProvider<org.daisy.pipeline.braille.common.BrailleTranslator>> brailleTranslatorProviders
	= new ArrayList<BrailleTranslatorProvider<org.daisy.pipeline.braille.common.BrailleTranslator>>();
	
	private final Provider.util.MemoizingProvider<Query,org.daisy.pipeline.braille.common.BrailleTranslator> brailleTranslatorProvider
	= memoize(dispatch(brailleTranslatorProviders));
	
	public boolean supportsSpecification(String locale, String mode) {
		try {
			factory.newTranslator(locale, mode);
			return true; }
		catch (TranslatorConfigurationException e) {
			return false; }
	}
	
	public Collection<TranslatorSpecification> listSpecifications() {
		return ImmutableList.of();
	}
	
	public BrailleTranslatorFactory newFactory() {
		return factory;
	}
	
	private BrailleTranslatorFactory factory = new BrailleTranslatorFactoryImpl();
	
	private class BrailleTranslatorFactoryImpl implements BrailleTranslatorFactory {
		public BrailleTranslator newTranslator(String locale, String mode) throws TranslatorConfigurationException {
			Matcher m = MODE.matcher(mode);
			if (!m.matches())
				throw new TranslatorConfigurationException();
			String query = m.group(1);
			if (query == null)
				query = "";
			if (!query.trim().equals("auto"))
				for (org.daisy.pipeline.braille.common.BrailleTranslator t : brailleTranslatorProvider.get(query(query)))
					try {
						return new BrailleTranslatorFromBrailleTranslator(mode, t.lineBreakingFromStyledText()); }
					catch (UnsupportedOperationException e) {}
			return new BrailleTranslatorFromFilter(mode, filterFactory.newFilter(locale, mode));
		}
	}
	
	public <T> void setReference(Class<T> c, T reference) throws TranslatorConfigurationException {}
	
	/**
	 * BrailleTranslator with <a
	 * href="http://snaekobbi.github.io/braille-css-spec/#h3_white-space-processing">white
	 * space processing</a> and <a
	 * href="http://snaekobbi.github.io/braille-css-spec/#line-breaking">line
	 * breaking</a> according to braille CSS.
	 *
	 * White space is normalised. Preserved spaces must have been converted to
	 * no-break spaces and preserved line feeds must have been converted to
	 * &lt;obfl:br/&gt;.
	 *
	 * Through setHyphenating() the translator can be made to perform
	 * automatic hyphenation or not. Regardless of this setting, hyphenation
	 * characters (SHY and ZWSP) in the input are always used in line
	 * breaking. These hyphenation characters must have been removed from the
	 * input when no breaking within words is desired at all (hyphens:none).
	 */
	private static class BrailleTranslatorFromFilter implements BrailleTranslator {
		
		private final String mode;
		private final BrailleFilter filter;
		
		private BrailleTranslatorFromFilter(String mode, BrailleFilter filter) {
			this.mode = mode;
			this.filter = filter;
		}
		
		public BrailleTranslatorResult translate(Translatable input) throws TranslationException {
			return new DefaultLineBreaker(filter.filter(input));
		}
		
		public String getTranslatorMode() {
			return mode;
		}
	}
	
	private static class BrailleTranslatorFromBrailleTranslator implements BrailleTranslator {
		
		private final String mode;
		private final org.daisy.pipeline.braille.common.BrailleTranslator.LineBreakingFromStyledText translator;
		
		private BrailleTranslatorFromBrailleTranslator(
				String mode,
				org.daisy.pipeline.braille.common.BrailleTranslator.LineBreakingFromStyledText translator) {
			this.mode = mode;
			this.translator = translator;
		}
		
		public BrailleTranslatorResult translate(Translatable input) throws TranslationException {
			if (input.getAttributes() == null && input.isHyphenating() == false) {
				String text = input.getText();
				if (" ".equals(text))
					return new DefaultLineBreaker("\u2800");
				if ("??".equals(text))
					return new DefaultLineBreaker("??");
				if (BRAILLE.matcher(text).matches())
					return new DefaultLineBreaker(text); }
			return translator.transform(cssStyledTextFromTranslatable(input));
		}
		
		public String getTranslatorMode() {
			return mode;
		}
	}
	
	private static final Logger logger = LoggerFactory.getLogger(BrailleTranslatorFactoryServiceImpl.class);
}
