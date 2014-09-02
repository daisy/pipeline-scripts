package org.daisy.pipeline.braille.liblouis.saxon;

import java.io.File;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.om.AtomicSequence;
import net.sf.saxon.om.EmptyAtomicSequence;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.liblouis.LiblouisTableResolver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.daisy.pipeline.braille.liblouis.LiblouisTablePath.tokenizeTableList;
import static org.daisy.pipeline.braille.Utilities.Strings.join;

@SuppressWarnings("serial")
public class ResolveTableDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("louis",
			"http://liblouis.org/liblouis", "resolve-table");
	
	private LiblouisTableResolver tableResolver = null;
	
	protected void bindTableResolver(LiblouisTableResolver tableResolver) {
		this.tableResolver = tableResolver;
	}
	
	protected void unbindTableResolver(LiblouisTableResolver tableResolver) {
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
			public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
				try {
					String resource = ((AtomicSequence)arguments[0]).getStringValue();
					File[] tableList = tableResolver.resolveTableList(tokenizeTableList(resource), null);
					if (tableList != null && tableList.length > 0) {
						String[] files = new String[tableList.length];
						for (int i = 0; i < tableList.length; i++)
							files[i] = tableList[i].getCanonicalPath();
						return new StringValue(join(files, ",")); }
					return EmptyAtomicSequence.getInstance(); }
				catch (Exception e) {
					logger.error("louis:resolve-table failed", e);
					throw new XPathException("louis:resolve-table failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(ResolveTableDefinition.class);

}
