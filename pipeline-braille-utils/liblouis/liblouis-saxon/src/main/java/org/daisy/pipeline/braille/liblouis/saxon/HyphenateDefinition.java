package org.daisy.pipeline.braille.liblouis.saxon;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("serial")
public class HyphenateDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("louis",
			"http://liblouis.org/liblouis", "hyphenate");
	
	private Liblouis liblouis = null;
	
	protected void bindLiblouis(Liblouis liblouis) {
		this.liblouis = liblouis;
	}
	
	protected void unbindLiblouis(Liblouis liblouis) {
		this.liblouis = null;
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
		return new SequenceType[] {
				SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING};
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
					String table = ((StringValue)arguments[0].next()).getStringValue();
					String text = ((StringValue)arguments[1].next()).getStringValue();
					return SingletonIterator.makeIterator(
							new StringValue(liblouis.hyphenate(table, text))); }
				catch (Exception e) {
					logger.error("louis:hyphenate failed", e);
					throw new XPathException("louis:hyphenate failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(HyphenateDefinition.class);
}
