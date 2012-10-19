package org.daisy.braille.css;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import cz.vutbr.web.css.CSSFactory;
import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.CSSProperty.TextAlign;
import cz.vutbr.web.css.CSSProperty.Orphans;
import cz.vutbr.web.css.CSSProperty.PageBreak;
import cz.vutbr.web.css.CSSProperty.PageBreakInside;
import cz.vutbr.web.css.CSSProperty.Widows;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermFactory;

import org.daisy.braille.css.BrailleCSSProperty.Border;
import org.daisy.braille.css.BrailleCSSProperty.Content;
import org.daisy.braille.css.BrailleCSSProperty.Display;
import org.daisy.braille.css.BrailleCSSProperty.ListStyleType;
import org.daisy.braille.css.BrailleCSSProperty.Margin;
import org.daisy.braille.css.BrailleCSSProperty.Padding;
import org.daisy.braille.css.BrailleCSSProperty.Page;
import org.daisy.braille.css.BrailleCSSProperty.StringSet;
import org.daisy.braille.css.BrailleCSSProperty.TextIndent;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/** 
 * @author bert
 */
public class SupportedBrailleCSS implements SupportedCSS {
	
	private static Logger log = LoggerFactory.getLogger(SupportedBrailleCSS.class);

	private static final int TOTAL_SUPPORTED_DECLARATIONS = 20;

	private static final TermFactory tf = CSSFactory.getTermFactory();

	private static final CSSProperty DEFAULT_UA_TEXT_ALIGN = TextAlign.LEFT;
	private static final Term<?> DEFAULT_UA_TEXT_IDENT = tf.createInteger(0);
	private static final Term<?> DEFAULT_UA_MARGIN = tf.createInteger(0);
	private static final Term<?> DEFAULT_UA_PADDING = tf.createInteger(0);
	private static final Term<?> DEFAULT_UA_ORPHANS = tf.createInteger(2);
	private static final Term<?> DEFAULT_UA_WIDOWS = tf.createInteger(2);

	private final static SupportedBrailleCSS instance;
	static {
		instance = new SupportedBrailleCSS();
	}

	private Map<String, CSSProperty> defaultCSSproperties;
	private Map<String, Term<?>> defaultCSSvalues;

	private Map<String, Integer> ordinals;
	private Map<Integer, String> ordinalsRev;

	private Set<String> supportedMedias;

	public final static SupportedBrailleCSS getInstance() {
		return instance;
	}

	private SupportedBrailleCSS() {
		this.setSupportedCSS();
		this.setOridinals();
		this.setSupportedAtKeywords();
	}

	public boolean isSupportedMedia(String media) {
		if (media == null)
			return false;

		return supportedMedias.contains(media.toLowerCase());
	}

	public final boolean isSupportedCSSProperty(String property) {
		return defaultCSSproperties.get(property) != null;
	}

	public final CSSProperty getDefaultProperty(String property) {
		CSSProperty value = defaultCSSproperties.get(property);
		log.debug("Asked for property {}'s default value: {}", property, value);
		return value;
	}

	public final Term<?> getDefaultValue(String property) {
		return defaultCSSvalues.get(property);
	}

	public final int getTotalProperties() {
		return defaultCSSproperties.size();
	}

	public final Set<String> getDefinedPropertyNames() {
		return defaultCSSproperties.keySet();
	}

	public String getRandomPropertyName() {
		final Random generator = new Random();
		int o = generator.nextInt(getTotalProperties());
		return getPropertyName(o);
	}

	public int getOrdinal(String propertyName) {
		Integer i = ordinals.get(propertyName);
		return (i == null) ? -1 : i.intValue();
	}

	public String getPropertyName(int o) {
		return ordinalsRev.get(o);
	}

	private void setSupportedCSS() {

		Map<String, CSSProperty> props = new HashMap<String, CSSProperty>(
				TOTAL_SUPPORTED_DECLARATIONS, 1.0f);

		Map<String, Term<?>> values = new HashMap<String, Term<?>>(
				TOTAL_SUPPORTED_DECLARATIONS, 1.0f);

		// text spacing
		props.put("text-align", DEFAULT_UA_TEXT_ALIGN);
		props.put("-brl-text-indent", TextIndent.integer);
		values.put("-brl-text-indent", DEFAULT_UA_TEXT_IDENT);

		// layout box
		props.put("-brl-margin-top", Margin.integer);
		values.put("-brl-margin-top", DEFAULT_UA_MARGIN);
		props.put("-brl-margin-right", Margin.integer);
		values.put("-brl-margin-right", DEFAULT_UA_MARGIN);
		props.put("-brl-margin-bottom", Margin.integer);
		values.put("-brl-margin-bottom", DEFAULT_UA_MARGIN);
		props.put("-brl-margin-left", Margin.integer);
		values.put("-brl-margin-left", DEFAULT_UA_MARGIN);

		props.put("-brl-padding-top", Padding.integer);
		values.put("-brl-padding-top", DEFAULT_UA_PADDING);
		props.put("-brl-padding-right", Padding.integer);
		values.put("-brl-padding-right", DEFAULT_UA_PADDING);
		props.put("-brl-padding-bottom", Padding.integer);
		values.put("-brl-padding-bottom", DEFAULT_UA_PADDING);
		props.put("-brl-padding-left", Padding.integer);
		values.put("-brl-padding-left", DEFAULT_UA_PADDING);

		props.put("-brl-border-top", Border.NONE);
		props.put("-brl-border-right", Border.NONE);
		props.put("-brl-border-bottom", Border.NONE);
		props.put("-brl-border-left", Border.NONE);

		// positioning
		props.put("-brl-display", Display.INLINE);

		// elements
		props.put("-brl-list-style-type", ListStyleType.NONE);

		// paged
		props.put("page", Page.AUTO);
		props.put("page-break-before", PageBreak.AUTO);
		props.put("page-break-after", PageBreak.AUTO);
		props.put("page-break-inside", PageBreakInside.AUTO);

		props.put("orphans", Orphans.integer);
		values.put("orphans", DEFAULT_UA_ORPHANS);
		props.put("widows", Widows.integer);
		values.put("widows", DEFAULT_UA_WIDOWS);

		// misc
		props.put("-brl-string-set", StringSet.NONE);
		props.put("-brl-content", Content.NONE); // NOTE: only allowed on :before and :after pseudo elements
		
		this.defaultCSSproperties = props;
		this.defaultCSSvalues = values;
	}

	private void setOridinals() {

		Map<String, Integer> ords = new HashMap<String, Integer>(
				getTotalProperties(), 1.0f);
		Map<Integer, String> ordsRev = new HashMap<Integer, String>(
				getTotalProperties(), 1.0f);

		int i = 0;
		for (String key : defaultCSSproperties.keySet()) {
			ords.put(key, i);
			ordsRev.put(i, key);
			i++;
		}

		this.ordinals = ords;
		this.ordinalsRev = ordsRev;

	}

	private void setSupportedAtKeywords() {
		
		Set<String> set = new HashSet<String>(Arrays.asList("embossed"));

		this.supportedMedias = set;
	}

}
