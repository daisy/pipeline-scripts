package org.daisy.pipeline.braille.liblouis.saxon;

import java.util.NoSuchElementException;

import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.AtomicSequence;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.liblouis.Liblouis;
import org.daisy.pipeline.braille.liblouis.LiblouisTranslator;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "louis:hyphenate",
	service = { ExtensionFunctionDefinition.class }
)
@SuppressWarnings("serial")
public class HyphenateDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("louis",
			"http://liblouis.org/liblouis", "hyphenate");
	
	private Liblouis liblouis = null;
	
	@Reference(
		name = "Liblouis",
		unbind = "unbindLiblouis",
		service = Liblouis.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
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
		return SequenceType.SINGLE_STRING;
	}
	
	public ExtensionFunctionCall makeCallExpression() {
		return new ExtensionFunctionCall() {
			public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
				try {
					String query = ((AtomicSequence)arguments[0]).getStringValue();
					Hyphenator hyphenator;
					try {
						hyphenator = (Hyphenator)Iterables.<LiblouisTranslator>filter(
							liblouis.get(query), isHyphenator).iterator().next(); }
					catch (NoSuchElementException e) {
						throw new RuntimeException("Could not find a translator for query: " + query); }
					String text = ((AtomicSequence)arguments[1]).getStringValue();
					return new StringValue(hyphenator.hyphenate(text)); }
				catch (Exception e) {
					logger.error("louis:hyphenate failed", e);
					throw new XPathException("louis:hyphenate failed"); }
			}
		};
	}
	
	private final Predicate<LiblouisTranslator> isHyphenator = new Predicate<LiblouisTranslator>() {
		public boolean apply(LiblouisTranslator translator) {
			return translator instanceof Hyphenator;
		}
	};
	
	private static final Logger logger = LoggerFactory.getLogger(HyphenateDefinition.class);
}
