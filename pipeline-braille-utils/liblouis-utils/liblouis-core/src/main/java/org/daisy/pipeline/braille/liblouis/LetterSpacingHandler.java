package org.daisy.pipeline.braille.liblouis;

import java.util.Map;

import com.google.common.base.Splitter;

import org.daisy.pipeline.braille.liblouis.impl.LiblouisTableJnaImplProvider;

import org.liblouis.TranslationException;
import org.liblouis.Translator;

import org.osgi.framework.BundleContext;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.framework.ServiceReference;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LetterSpacingHandler {
	
	private Translator table;
	
	public LetterSpacingHandler(Translator table) {
		this.table = table;
	}
	
	public LetterSpacingHandler(String tableQuery, BundleContext context) {
		try {
			for (ServiceReference<LiblouisTableJnaImplProvider> ref :
				     context.getServiceReferences(LiblouisTableJnaImplProvider.class, null)) {
				LiblouisTableJnaImplProvider provider = context.getService(ref);
				this.table = provider.get(tableQuery).iterator().next().getTranslator();
				break; }}
		catch (InvalidSyntaxException e) {
			throw new RuntimeException(e); }
	}
	
	// @jukkae FIXME
	public String translateWithSpacing(String text, int letterSpacing) {
		// return translateWithSpacing(text, letterSpacing, 2 * letterSpacing + 1)
		try {
			return table.translate(textFromLetterSpacing(text, letterSpacing), null, null).getBraille(); }
		catch (TranslationException e) {
			throw new RuntimeException(e); }
	}
	
	// @jukkae FIXME
	public String translateWithSpacing(String text, int letterSpacing, int wordSpacing) {
		throw new UnsupportedOperationException("Not implemented");
	}
	
	private final static Splitter.MapSplitter CSS_PARSER
	= Splitter.on(';').omitEmptyStrings().withKeyValueSeparator(Splitter.on(':').limit(2).trimResults());
	
	public static int letterSpacingFromInlineCSS(String style) {
		return letterSpacingFromInlineCSS(CSS_PARSER.split(style));
	}
	
	public static int letterSpacingFromInlineCSS(Map<String,String> style) {
		int letterSpacing = 0;
		for (String prop : style.keySet()) {
			String value = style.get(prop);
			if (prop.equals("letter-spacing") && (!value.equals("0")))
				letterSpacing = Integer.parseInt(value);
			else
				logger.warn("Inline CSS property {} not supported", prop);
			}
		return letterSpacing;
	}
	
	//TODO: Handle numbers according to Finnish braille specification
	public static String textFromLetterSpacing(String text, int letterSpacing) {
		if (letterSpacing >= 1) {
			String spaces = "";
			for (int i = 0; i < letterSpacing; i++) {
				spaces += " ";
			}
			text = text.replaceAll(".(?=.)", String.format("$0%s", spaces));
		}
		if (letterSpacing < 0)
			logger.warn("letter-spacing: {} not supported, must be non-negative", letterSpacing);
		return text;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(LetterSpacingHandler.class);
	
}
