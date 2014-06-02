package org.daisy.pipeline.braille.dotify.saxon;

import java.util.HashMap;
import java.util.Map;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.AtomicSequence;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.dotify.text.FilterLocale;
import org.daisy.dotify.translator.BrailleTranslator;
import org.daisy.dotify.translator.BrailleTranslatorFactory;
import org.daisy.dotify.translator.BrailleTranslatorFactoryMaker;
import org.daisy.dotify.translator.UnsupportedSpecificationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TranslateDefinition extends ExtensionFunctionDefinition {

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
			
			@SuppressWarnings({ "rawtypes", "unchecked" })
			@Override
			public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
				try {
					String locale = ((AtomicSequence)arguments[0]).getStringValue();
					String text = ((AtomicSequence)arguments[1]).getStringValue();
					return new StringValue(getBrailleTranslator(locale).translate(text).getTranslatedRemainder()); }
				catch (Exception e) {
					logger.error("dotify:translate failed", e);
					throw new XPathException("dotify:translate failed"); }
			}
			
			private static final long serialVersionUID = 1L;
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

	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(TranslateDefinition.class);
}
