package org.daisy.pipeline.braille.dotify.saxon;

import java.util.HashMap;
import java.util.Map;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.EmptyIterator;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.dotify.text.FilterLocale;
import org.daisy.dotify.translator.BrailleTranslator;
import org.daisy.dotify.translator.BrailleTranslatorFactory;
import org.daisy.dotify.translator.BrailleTranslatorFactoryMaker;
import org.daisy.dotify.translator.UnsupportedSpecificationException;

public class TranslateDefinition extends ExtensionFunctionDefinition {

	private static final long serialVersionUID = 1L;

	private static final StructuredQName funcname = new StructuredQName("dotify",
			"http://code.google.com/p/dotify/", "translate");
	
	@Override
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

	@Override
	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING };
	}

	@Override
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.OPTIONAL_STRING;
	}

	@Override
	public ExtensionFunctionCall makeCallExpression() {
		return new ExtensionFunctionCall() {
			
			private static final long serialVersionUID = 1L;
			
			@SuppressWarnings({ "rawtypes", "unchecked" })
			@Override
			public SequenceIterator call(SequenceIterator[] arguments, XPathContext context)
					throws XPathException {
				
				StringValue locale = (StringValue)arguments[0].next();
				if (locale == null)
					return EmptyIterator.getInstance();
				StringValue text = (StringValue)arguments[1].next();
				if (text == null)
					return EmptyIterator.getInstance();
				try {
					return SingletonIterator.makeIterator(new StringValue(
						getBrailleTranslator(locale.getStringValue())
						.translate(text.getStringValue()).getTranslatedRemainder())); }
				catch (Exception e) {
					throw new RuntimeException("Could not complete translation", e); }
			}
		};
	}
	
	private final BrailleTranslatorFactoryMaker factory = BrailleTranslatorFactoryMaker.newInstance();
	private final Map<String,BrailleTranslator> cache = new HashMap<String,BrailleTranslator>();
	
	private BrailleTranslator getBrailleTranslator(String locale)
			throws UnsupportedSpecificationException {
				
		BrailleTranslator translator = cache.get(locale);
		if (translator == null) {
			// The only supported locale at this time is sv_SE
			translator = factory.newBrailleTranslator(
					FilterLocale.parse(locale), BrailleTranslatorFactory.MODE_UNCONTRACTED);
				translator.setHyphenating(false);
				cache.put(locale, translator); }
		return translator;
	}
}
