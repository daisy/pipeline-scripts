package org.daisy.pipeline.braille.tex.saxon;

import java.net.URI;
import java.net.URL;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.AtomicSequence;
import net.sf.saxon.om.EmptyAtomicSequence;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.tex.TexHyphenatorTableResolver;

import static org.daisy.pipeline.braille.Utilities.URIs.asURI;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("serial")
public class ResolveTableDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("louis",
			"http://code.google.com/p/texhyphj/", "resolve-table");
	
	private TexHyphenatorTableResolver tableResolver = null;
	
	protected void bindTableResolver(TexHyphenatorTableResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	protected void unbindTableResolver(TexHyphenatorTableResolver tableResolver) {
		this.tableResolver = null;
	}
	
	public StructuredQName getFunctionQName() {
		return funcname;
	}
	
	@Override
	public int getMinimumNumberOfArguments() {
		return 1;
	}
	
	@Override
	public int getMaximumNumberOfArguments() {
		return 1;
	}
	
	public SequenceType[] getArgumentTypes() {
		return new SequenceType[] { SequenceType.SINGLE_STRING };
	}
	
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.OPTIONAL_STRING;
	}
	
	public ExtensionFunctionCall makeCallExpression() {
		
		return new ExtensionFunctionCall() {
			
			@SuppressWarnings({ "rawtypes", "unchecked" })
			public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
				try {
					URI resource = asURI(((AtomicSequence)arguments[0]).getStringValue());
					URL table = tableResolver.resolve(resource);
					if (table != null)
						return new StringValue(table.toString());
					return EmptyAtomicSequence.getInstance(); }
				catch (Exception e) {
					logger.error("tex:resolve-table failed", e);
					throw new XPathException("tex:resolve-table failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(ResolveTableDefinition.class);
}
