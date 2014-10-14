package org.daisy.pipeline.braille.common.saxon;

import java.util.ArrayList;
import java.util.List;

import net.sf.saxon.expr.XPathContext;
import net.sf.saxon.lib.ExtensionFunctionCall;
import net.sf.saxon.lib.ExtensionFunctionDefinition;
import net.sf.saxon.om.Sequence;
import net.sf.saxon.om.StructuredQName;
import net.sf.saxon.trans.XPathException;
import net.sf.saxon.value.SequenceType;
import net.sf.saxon.value.StringValue;

import org.daisy.pipeline.braille.common.Cached;
import org.daisy.pipeline.braille.common.Translator;
import org.daisy.pipeline.braille.common.TranslatorProvider;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings({"serial","rawtypes","unchecked"})
public class TranslateDefinition extends ExtensionFunctionDefinition {
	
	private static final StructuredQName funcname = new StructuredQName("pf",
			"http://www.daisy.org/ns/pipeline/functions", "translate");
	
	protected void bindTranslatorProvider(TranslatorProvider provider) {
		providers.add(provider);
		logger.debug("Adding braille translator provider: {}", provider);
	}
	
	protected void unbindTranslatorProvider(TranslatorProvider provider) {
		providers.remove(provider);
		translators.invalidateCache();
		logger.debug("Removing braille translator provider: {}", provider);
	}
	
	private List<TranslatorProvider> providers = new ArrayList<TranslatorProvider>();
	
	private Cached<String,Translator> translators = new Cached<String,Translator>() {
		public Translator delegate(String query) {
			for (TranslatorProvider provider : providers) {
				Translator t = (Translator)provider.get(query);
				if (t != null) return t; }
			return null;
		}
	};
	
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
			public Sequence call(XPathContext context, Sequence[] arguments) throws XPathException {
				try {
					String query = arguments[0].head().getStringValue();
					String text = arguments[1].head().getStringValue();
					Translator translator = translators.get(query);
					if (translator == null)
						throw new RuntimeException("Could not find a translator for query: " + query);
					return new StringValue(translator.translate(text)); }
				catch (Exception e) {
					logger.error("pf:translate failed", e);
					throw new XPathException("pf:translate failed"); }
			}
		};
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TranslateDefinition.class);
	
}
