package org.daisy.braille.css;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import cz.vutbr.web.css.CSSFactory;
import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.CSSProperty.CounterReset;
import cz.vutbr.web.css.CSSProperty.Orphans;
import cz.vutbr.web.css.CSSProperty.PageBreak;
import cz.vutbr.web.css.CSSProperty.PageBreakInside;
import cz.vutbr.web.css.CSSProperty.TextAlign;
import cz.vutbr.web.css.CSSProperty.Widows;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermFactory;

import org.daisy.braille.css.BrailleCSSProperty.AbsoluteMargin;
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
	
	private static final int TOTAL_SUPPORTED_DECLARATIONS = 31;
	
	private static final TermFactory tf = CSSFactory.getTermFactory();
	
	private static final CSSProperty DEFAULT_UA_TEXT_ALIGN = TextAlign.LEFT;
	private static final Term<?> DEFAULT_UA_TEXT_IDENT = tf.createInteger(0);
	private static final Term<?> DEFAULT_UA_MARGIN = tf.createInteger(0);
	private static final Term<?> DEFAULT_UA_PADDING = tf.createInteger(0);
	private static final Term<?> DEFAULT_UA_ORPHANS = tf.createInteger(2);
	private static final Term<?> DEFAULT_UA_WIDOWS = tf.createInteger(2);
	
	private Map<String, CSSProperty> defaultCSSproperties;
	private Map<String, Term<?>> defaultCSSvalues;
	
	private Map<String, Integer> ordinals;
	private Map<Integer, String> ordinalsRev;
	
	private Set<String> properties;
	
	private static SupportedBrailleCSS instance;
	
	public final static SupportedBrailleCSS getInstance() {
		if (instance == null)
			instance = new SupportedBrailleCSS();
		return instance;
	}
	
	private SupportedBrailleCSS() {
		this.setSupportedCSS();
		this.setOridinals();
	}
	
	@Override
	public boolean isSupportedMedia(String media) {
		if (media == null)
			return false;
		return media.toLowerCase().equals("embossed");
	}
	
	@Override
	public final boolean isSupportedCSSProperty(String property) {
		return properties.contains(property);
	}
	
	@Override
	public final CSSProperty getDefaultProperty(String property) {
		CSSProperty value = defaultCSSproperties.get(property);
		log.debug("Asked for property {}'s default value: {}", property, value);
		return value;
	}
	
	@Override
	public final Term<?> getDefaultValue(String property) {
		return defaultCSSvalues.get(property);
	}
	
	@Override
	public final int getTotalProperties() {
		return defaultCSSproperties.size();
	}
	
	@Override
	public final Set<String> getDefinedPropertyNames() {
		return defaultCSSproperties.keySet();
	}
	
	@Override
	public String getRandomPropertyName() {
		final Random generator = new Random();
		int o = generator.nextInt(getTotalProperties());
		return getPropertyName(o);
	}
	
	@Override
	public int getOrdinal(String propertyName) {
		Integer i = ordinals.get(propertyName);
		return (i == null) ? -1 : i.intValue();
	}
	
	@Override
	public String getPropertyName(int o) {
		return ordinalsRev.get(o);
	}
	
	private void setSupportedCSS() {
		
		Map<String, CSSProperty> props = new HashMap<String, CSSProperty>(TOTAL_SUPPORTED_DECLARATIONS, 1.0f);
		Map<String, Term<?>> values = new HashMap<String, Term<?>>(TOTAL_SUPPORTED_DECLARATIONS, 1.0f);
		
		properties = new HashSet<String>();
		
		// text spacing
		props.put("text-align", DEFAULT_UA_TEXT_ALIGN);
		properties.add("text-align");
		props.put("text-indent", TextIndent.integer);
		values.put("text-indent", DEFAULT_UA_TEXT_IDENT);
		properties.add("text-indent");
		
		// layout box
		props.put("left", AbsoluteMargin.integer);
		values.put("left", DEFAULT_UA_MARGIN);
		properties.add("left");
		props.put("right", AbsoluteMargin.integer);
		values.put("right", DEFAULT_UA_MARGIN);
		properties.add("right");
		
		props.put("margin", Margin.component_values);
		properties.add("margin");
		props.put("margin-top", Margin.integer);
		values.put("margin-top", DEFAULT_UA_MARGIN);
		properties.add("margin-top");
		props.put("margin-right", Margin.integer);
		values.put("margin-right", DEFAULT_UA_MARGIN);
		properties.add("margin-right");
		props.put("margin-bottom", Margin.integer);
		values.put("margin-bottom", DEFAULT_UA_MARGIN);
		properties.add("margin-bottom");
		props.put("margin-left", Margin.integer);
		values.put("margin-left", DEFAULT_UA_MARGIN);
		properties.add("margin-left");

		props.put("padding", Padding.component_values);
		properties.add("padding");
		props.put("padding-top", Padding.integer);
		values.put("padding-top", DEFAULT_UA_PADDING);
		properties.add("padding-top");
		props.put("padding-right", Padding.integer);
		values.put("padding-right", DEFAULT_UA_PADDING);
		properties.add("padding-right");
		props.put("padding-bottom", Padding.integer);
		values.put("padding-bottom", DEFAULT_UA_PADDING);
		properties.add("padding-bottom");
		props.put("padding-left", Padding.integer);
		values.put("padding-left", DEFAULT_UA_PADDING);
		properties.add("padding-left");
		
		props.put("border", Border.component_values);
		properties.add("border");
		props.put("border-top", Border.NONE);
		properties.add("border-top");
		props.put("border-right", Border.NONE);
		properties.add("border-right");
		props.put("border-bottom", Border.NONE);
		properties.add("border-bottom");
		props.put("border-left", Border.NONE);
		properties.add("border-left");
		
		// positioning
		props.put("display", Display.INLINE);
		properties.add("display");
		
		// elements
		props.put("list-style-type", ListStyleType.NONE);
		properties.add("list-style-type");
		
		// paged
		props.put("page", Page.AUTO);
		properties.add("page");
		props.put("page-break-before", PageBreak.AUTO);
		properties.add("page-break-before");
		props.put("page-break-after", PageBreak.AUTO);
		properties.add("page-break-after");
		props.put("page-break-inside", PageBreakInside.AUTO);
		properties.add("page-break-inside");
		props.put("orphans", Orphans.integer);
		values.put("orphans", DEFAULT_UA_ORPHANS);
		properties.add("orphans");
		props.put("widows", Widows.integer);
		values.put("widows", DEFAULT_UA_WIDOWS);
		properties.add("widows");
		
		// misc
		props.put("counter-reset", CounterReset.NONE);
		properties.add("counter-reset");
		props.put("string-set", StringSet.NONE);
		properties.add("string-set");
		props.put("content", Content.NONE);
		properties.add("content");
		
		this.defaultCSSproperties = props;
		this.defaultCSSvalues = values;
		
	}
	
	private void setOridinals() {
		
		Map<String, Integer> ords = new HashMap<String, Integer>(getTotalProperties(), 1.0f);
		Map<Integer, String> ordsRev = new HashMap<Integer, String>(getTotalProperties(), 1.0f);
		
		int i = 0;
		for (String key : defaultCSSproperties.keySet()) {
			ords.put(key, i);
			ordsRev.put(i, key);
			i++;
		}
		
		this.ordinals = ords;
		this.ordinalsRev = ordsRev;
		
	}
}
