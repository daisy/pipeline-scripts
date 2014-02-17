package org.daisy.pipeline.braille.libhyphen.saxon;

import java.net.URI;
import java.net.URL;

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

import org.daisy.pipeline.braille.libhyphen.LibhyphenTableResolver;

import static org.daisy.pipeline.braille.Utilities.URIs.asURI;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("serial")
public class ResolveTableDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("hyphen",
			"http://hunspell.sourceforge.net/Hyphen", "resolve-table");
	
	private LibhyphenTableResolver tableResolver = null;
	
	protected void bindTableResolver(LibhyphenTableResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	protected void unbindTableResolver(LibhyphenTableResolver tableResolver) {
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
			public SequenceIterator call(SequenceIterator[] arguments, XPathContext context)
					throws XPathException {
				
				try {
					URI resource = asURI(((StringValue)arguments[0].next()).getStringValue());
					URL table = tableResolver.resolve(resource);
					if (table != null)
						return SingletonIterator.makeIterator(new StringValue(table.toString()));
					return EmptyIterator.getInstance();  }
				catch (Exception e) {
					logger.error("hyphen:resolve-table failed", e);
					throw new XPathException("hyphen:resolve-table failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(ResolveTableDefinition.class);
}
