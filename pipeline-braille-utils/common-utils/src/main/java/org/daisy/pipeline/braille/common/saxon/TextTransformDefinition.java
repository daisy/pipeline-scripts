package org.daisy.pipeline.braille.common.saxon;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.common.Provider;
import org.daisy.pipeline.braille.common.Provider.CachedProvider;
import org.daisy.pipeline.braille.common.Provider.DispatchingProvider;
import org.daisy.pipeline.braille.common.TextTransform;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "pf:text-transform",
	service = { ExtensionFunctionDefinition.class }
)
@SuppressWarnings({"serial"})
public class TextTransformDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("pf",
			"http://www.daisy.org/ns/pipeline/functions", "text-transform");
	
	@Reference(
		name = "TextTransformProvider",
		unbind = "unbindTextTransformProvider",
		service = TextTransform.Provider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	protected void bindTextTransformProvider(TextTransform.Provider<?> provider) {
		providers.add(provider);
		logger.debug("Adding TextTransform provider: {}", provider);
	}
	
	protected void unbindTextTransformProvider(TextTransform.Provider<?> provider) {
		providers.remove(provider);
		translators.invalidateCache();
		logger.debug("Removing TextTransform provider: {}", provider);
	}
	
	private List<Provider<String,? extends TextTransform>> providers = new ArrayList<Provider<String,? extends TextTransform>>();
	
	private CachedProvider<String,TextTransform> translators
		= CachedProvider.<String,TextTransform>newInstance(
			DispatchingProvider.<String,TextTransform>newInstance(providers));
	
	public StructuredQName getFunctionQName() {
		return funcname;
	}
	
	@Override
	public int getMinimumNumberOfArguments() {
		return 2;
	}
	
	@Override
	public int getMaximumNumberOfArguments() {
		return 2;
	}
	
	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] {
				SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING };
	}
	
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.OPTIONAL_STRING;
	}
	
	public ExtensionFunctionCall makeCallExpression() {
		return new ExtensionFunctionCall() {
			public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
				try {
					String query = arguments[0].head().getStringValue();
					String text = arguments[1].head().getStringValue();
					TextTransform translator;
					try { translator = translators.get(query).iterator().next(); }
					catch (NoSuchElementException e) {
						throw new RuntimeException("Could not find a translator for query: " + query); }
					return new StringValue(translator.transform(text)); }
				catch (Exception e) {
					logger.error("pf:text-transform failed", e);
					throw new XPathException("pf:text-transform failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TextTransformDefinition.class);
	
}
