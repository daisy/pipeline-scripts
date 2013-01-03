package org.daisy.pipeline.braille.pef.saxon;

import java.util.HashMap;
import java.util.Map;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.SequenceIterator;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.tree.iter.SingletonIterator;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.braille.table.TableCatalog;
import org.daisy.braille.table.BrailleConverter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class EncodeDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("pef",
			"http://www.daisy.org/ns/2008/pef", "encode");
	
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
		return new SequenceType[] {
				SequenceType.SINGLE_STRING,
				SequenceType.SINGLE_STRING};
	}
	
	@Override
	public SequenceType getResultType(SequenceType[] suppliedArgumentTypes) {
		return SequenceType.OPTIONAL_STRING;
	}
	
	private final TableCatalog catalog = TableCatalog.newInstance();
	private final Map<String,BrailleConverter> tables = new HashMap<String,BrailleConverter>();
	
	@Override
	public ExtensionFunctionCall makeCallExpression() {
		
		return new ExtensionFunctionCall() {
			
			@SuppressWarnings({ "unchecked", "rawtypes" })
			@Override
			public SequenceIterator call(SequenceIterator[] arguments, XPathContext context)
					throws XPathException {
				
				try {
					String tableId = ((StringValue)arguments[0].next()).getStringValue();
					String braille = ((StringValue)arguments[1].next()).getStringValue();
					BrailleConverter table = tables.get(tableId);
					if (table == null)
						table = catalog.get(tableId).newBrailleConverter();
					tables.put(tableId, table);
					return SingletonIterator.makeIterator(
							new StringValue(table.toText(braille))); }
				catch (Exception e) {
					logger.error("pef:encode failed", e);
					throw new XPathException("pef:encode failed"); }
			}
			
			private static final long serialVersionUID = 1L;
		};
	}
	
	private static final long serialVersionUID = 1L;
	private static final Logger logger = LoggerFactory.getLogger(EncodeDefinition.class);
}
