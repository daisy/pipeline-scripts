package org.daisy.pipeline.braille.libhyphen.saxon;

import java.net.URI;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.libhyphen.Libhyphen;

import static org.daisy.pipeline.braille.Utilities.URIs.asURI;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("serial")
public class HyphenateDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("hyphen",
			"http://hunspell.sourceforge.net/Hyphen", "hyphenate");
	
	private Libhyphen libhyphen = null;
	
	protected void bindLibhyphen(Libhyphen libhyphen) {
		this.libhyphen = libhyphen;
	}
	
	protected void unbindLibhyphen(Libhyphen libhyphen) {
		this.libhyphen = null;
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
			public SequenceIterator call(SequenceIterator[] arguments, XPathContext context)
					throws XPathException {
				
				try {
					URI table = asURI(((StringValue)arguments[0].next()).getStringValue());
					String text = ((StringValue)arguments[1].next()).getStringValue();
					return SingletonIterator.makeIterator(
						new StringValue(libhyphen.hyphenate(table, text))); }
				catch (Exception e) {
					logger.error("hyphen:hyphenate failed", e);
					throw new XPathException("hyphen:hyphenate failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(HyphenateDefinition.class);
}
