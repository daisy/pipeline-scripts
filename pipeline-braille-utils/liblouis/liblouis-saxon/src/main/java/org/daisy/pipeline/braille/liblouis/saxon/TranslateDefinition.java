package org.daisy.pipeline.braille.liblouis.saxon;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.BooleanValue;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("serial")
public class TranslateDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("louis",
			"http://liblouis.org/liblouis", "translate");
	
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
		return 4;
	}
	
	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] {
				SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_BOOLEAN,
				SequenceType.OPTIONAL_STRING};
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
					boolean hyphenated = false;
					byte[] typeform = null;
					if (arguments.length > 2) {
						hyphenated = ((BooleanValue)arguments[2].next()).getBooleanValue();
						if (arguments.length > 3) {
							if (arguments[3].next() != null) {
								typeform = ((StringValue)arguments[3].current()).getStringValue().getBytes();
								for (int i=0; i < typeform.length; i++)
									typeform[i] -= 48; }}}
					return SingletonIterator.makeIterator(
							new StringValue(liblouis.translate(table, text, hyphenated, typeform))); }
				catch (Exception e) {
					logger.error("louis:translate failed", e);
					throw new XPathException("louis:translate failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TranslateDefinition.class);
}