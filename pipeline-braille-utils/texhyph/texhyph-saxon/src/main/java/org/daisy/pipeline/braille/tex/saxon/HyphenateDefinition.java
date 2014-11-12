package org.daisy.pipeline.braille.tex.saxon;

import java.util.NoSuchElementException;

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
import org.daisy.pipeline.braille.tex.TexHyphenatorProvider;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "tex:hyphenate",
	service = { ExtensionFunctionDefinition.class }
)
@SuppressWarnings("serial")
public class HyphenateDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("tex",
			"http://code.google.com/p/texhyphj/", "hyphenate");
	
	private TexHyphenatorProvider provider = null;
	
	@Reference(
		name = "TexHyphenatorProvider",
		unbind = "unbindHyphenatorProvider",
		service = TexHyphenatorProvider.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindHyphenatorProvider(TexHyphenatorProvider provider) {
		this.provider = provider;
	}
	
	protected void unbindHyphenatorProvider(TexHyphenatorProvider provider) {
		this.provider = null;
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
					String query = ((AtomicSequence)arguments[0]).getStringValue();
					TexHyphenator hyphenator;
					try { hyphenator = provider.get(query).iterator().next(); }
					catch (NoSuchElementException e) {
						throw new RuntimeException("Could not find a hyphenator for query: " + query); }
					String text = ((AtomicSequence)arguments[1]).getStringValue();
					return new StringValue(hyphenator.hyphenate(text)); }
				catch (Exception e) {
					logger.error("tex:hyphenate failed", e);
					throw new XPathException("tex:hyphenate failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(HyphenateDefinition.class);
	
}
