package org.daisy.pipeline.braille.common.saxon.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

import static com.google.common.collect.Iterables.filter;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceExtent;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledTextTransform;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;

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
@SuppressWarnings("serial")
public class TextTransformDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("pf",
			"http://www.daisy.org/ns/pipeline/functions", "text-transform");
	
	@Reference(
		name = "TextTransformProvider",
		unbind = "unbindTextTransformProvider",
		service = BrailleTranslator.Provider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	@SuppressWarnings(
		"unchecked" // safe cast to TransformProvider<BrailleTranslator>
	)
	protected void bindTextTransformProvider(BrailleTranslator.Provider<?> provider) {
		providers.add((TransformProvider<BrailleTranslator>)provider);
		logger.debug("Adding BrailleTranslator provider: {}", provider);
	}
	
	protected void unbindTextTransformProvider(BrailleTranslator.Provider<?> provider) {
		providers.remove(provider);
		translators.invalidateCache();
		logger.debug("Removing BrailleTranslator provider: {}", provider);
	}
	
	private List<TransformProvider<BrailleTranslator>> providers = new ArrayList<TransformProvider<BrailleTranslator>>();
	
	private Provider.util.MemoizingProvider<String,BrailleTranslator> translators
	= memoize(dispatch(providers));
	
	public StructuredQName getFunctionQName() {
		return funcname;
	}
	
	@Override
	public int getMinimumNumberOfArguments() {
		return 2;
	}
	
	@Override
	public int getMaximumNumberOfArguments() {
		return 3;
	}
	
	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] {
			SequenceType.SINGLE_STRING,
			SequenceType.ATOMIC_SEQUENCE,
			SequenceType.ATOMIC_SEQUENCE
		};
	}
	
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.ATOMIC_SEQUENCE;
	}
	
	public ExtensionFunctionCall makeCallExpression() {
		return new ExtensionFunctionCall() {
			public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
				try {
					String query = arguments[0].head().getStringValue();
					String[] text = sequenceToArray(arguments[1]);
					try {
						if (arguments.length > 2) {
							String[] style = sequenceToArray(arguments[2]);
							if (style.length != text.length)
								throw new RuntimeException("Lengths of text and style sequences must match");
							CSSStyledTextTransform translator = filter(translators.get(query), CSSStyledTextTransform.class).iterator().next();
							return arrayToSequence(translator.transform(text, style)); }
						else {
							BrailleTranslator translator = translators.get(query).iterator().next();
							return arrayToSequence(translator.transform(text)); }}
					catch (NoSuchElementException e) {
						throw new RuntimeException("Could not find a translator for query: " + query); }}
				catch (Exception e) {
					logger.error("pf:text-transform failed", e);
					throw new XPathException("pf:text-transform failed"); }
			}
		};
	}
	
	private static String[] sequenceToArray(Sequence seq) throws XPathException {
		List<String> list = new ArrayList<String>();
		for (SequenceIterator<?> i = seq.iterate(); i.next() != null;)
			list.add(i.current().getStringValue());
		return list.toArray(new String[list.size()]);
	}
	
	private static Sequence arrayToSequence(String[] array) {
		List<StringValue> list = new ArrayList<StringValue>();
		for (String s : array)
			list.add(new StringValue(s));
		return new SequenceExtent<StringValue>(list);
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TextTransformDefinition.class);
	
}
