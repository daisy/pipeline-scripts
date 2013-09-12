package org.daisy.braille.css;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import cz.vutbr.web.css.CSSFactory;
import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermFactory;

import cz.vutbr.web.css.CSSProperty.Color;
import cz.vutbr.web.css.CSSProperty.FontStyle;
import cz.vutbr.web.css.CSSProperty.FontWeight;
import cz.vutbr.web.css.CSSProperty.TextDecoration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/** 
 * @author Bert Frees
 */
public class SupportedPrintCSS implements SupportedCSS {
	
	private static Logger log = LoggerFactory.getLogger(SupportedPrintCSS.class);

	private static final int TOTAL_SUPPORTED_DECLARATIONS = 4;

	private static final TermFactory tf = CSSFactory.getTermFactory();

	private static final Term<?> DEFAULT_UA_COLOR = tf.createColor("#000000");

	private final static SupportedPrintCSS instance;
	static {
		instance = new SupportedPrintCSS();
	}

	private Map<String, CSSProperty> defaultCSSproperties;
	private Map<String, Term<?>> defaultCSSvalues;

	private Map<String, Integer> ordinals;
	private Map<Integer, String> ordinalsRev;

	private Set<String> supportedMedias;

	public final static SupportedPrintCSS getInstance() {
		return instance;
	}

	private SupportedPrintCSS() {
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

		// text type
		props.put("color", Color.color);
		values.put("color", DEFAULT_UA_COLOR);
		props.put("font-style", FontStyle.NORMAL);
		props.put("font-weight", FontWeight.NORMAL);
		props.put("text-decoration", TextDecoration.NONE);
		
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
