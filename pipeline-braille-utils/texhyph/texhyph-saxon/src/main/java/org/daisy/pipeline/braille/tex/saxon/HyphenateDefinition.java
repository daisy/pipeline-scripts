package org.daisy.pipeline.braille.tex.saxon;

import java.net.URI;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.AtomicSequence;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.tex.TexHyphenator;

import static org.daisy.pipeline.braille.Utilities.URIs.asURI;

@SuppressWarnings("serial")
public class HyphenateDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("tex",
			"http://code.google.com/p/texhyphj/", "hyphenate");
	
	private TexHyphenator hyphenator = null;
	
	protected void bindHyphenator(TexHyphenator hyphenator) {
		this.hyphenator = hyphenator;
	}
	
	protected void unbindHyphenator(TexHyphenator hyphenator) {
		this.hyphenator = null;
	}
	
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
		return new SequenceType[] { SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING };
	}
	
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.OPTIONAL_STRING;
	}
	
	public ExtensionFunctionCall makeCallExpression() {
		return new ExtensionFunctionCall() {
			
			@SuppressWarnings({ "unchecked", "rawtypes" })
			public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
				try {
					URI table = asURI(((AtomicSequence)arguments[0]).getStringValue());
					String text = ((AtomicSequence)arguments[1]).getStringValue();
					return new StringValue(hyphenator.hyphenate(table, text)); }
				catch (Exception e) {
					logger.error("tex:hyphenate failed", e);
					throw new XPathException("tex:hyphenate failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(HyphenateDefinition.class);
}
