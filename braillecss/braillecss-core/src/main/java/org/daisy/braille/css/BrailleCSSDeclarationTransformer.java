package org.daisy.braille.css;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.daisy.braille.css.BrailleCSSProperty.Border;
import org.daisy.braille.css.BrailleCSSProperty.Content;
import org.daisy.braille.css.BrailleCSSProperty.Display;
import org.daisy.braille.css.BrailleCSSProperty.ListStyleType;
import org.daisy.braille.css.BrailleCSSProperty.Margin;
import org.daisy.braille.css.BrailleCSSProperty.Padding;
import org.daisy.braille.css.BrailleCSSProperty.Page;
import org.daisy.braille.css.BrailleCSSProperty.StringSet;
import org.daisy.braille.css.BrailleCSSProperty.TextIndent;

import cz.vutbr.web.css.CSSFactory;
import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.Declaration;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermFactory;
import cz.vutbr.web.css.TermFunction;
import cz.vutbr.web.css.TermIdent;
import cz.vutbr.web.css.TermInteger;
import cz.vutbr.web.css.TermList;
import cz.vutbr.web.css.TermNumber;
import cz.vutbr.web.css.TermString;
import cz.vutbr.web.domassign.DeclarationTransformer;

public class BrailleCSSDeclarationTransformer {
	
	private static final SupportedCSS css = SupportedBrailleCSS.getInstance();
	
	private static DeclarationTransformer backingInstance;
	private static BrailleCSSDeclarationTransformer instance;
	static {
		backingInstance = DeclarationTransformer.getInstance();
		instance = new BrailleCSSDeclarationTransformer();
	}
	
	public static final BrailleCSSDeclarationTransformer getInstance() {
		return instance;
	}
	
	public boolean parseDeclaration(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {

		String propertyName = d.getProperty().toLowerCase();
		
		if (!css.isSupportedCSSProperty(propertyName)) {
			propertyName = "-brl-" + propertyName;
			if (!css.isSupportedCSSProperty(propertyName)) {
				return false;
			}
		}

		try {
			Method m = methods.get(propertyName);
			if (m != null) {
				return (Boolean)m.invoke(this, d, properties, values);
			} else {
				return backingInstance.parseDeclaration(d, properties, values);
			}			
		} catch (Exception e) {
		}
		
		return false;
	}

	private Map<String, Method> methods;
	private static final TermFactory tf = CSSFactory.getTermFactory();
	
	private BrailleCSSDeclarationTransformer() {
		this.methods = parsingMethods();
	}
	
	private Map<String, Method> parsingMethods() {
		Map<String, Method> map = new HashMap<String, Method>(css
				.getTotalProperties(), 1.0f);
		for (String key : css.getDefinedPropertyNames()) {
			try {
				if (key.startsWith("-brl-")) {
					Method m = BrailleCSSDeclarationTransformer.class.getDeclaredMethod(
							DeclarationTransformer.camelCase("process" + key),
							Declaration.class, Map.class, Map.class);
					map.put(key, m);
				}
			} catch (Exception e) {
			}
		}
		return map;
	}
	
	/****************************************************************
	 * PROCESSING METHODS
	 ****************************************************************/
	
	@SuppressWarnings("unused")
	private boolean processBrlBorderBottom(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(Border.class, Border.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlBorderLeft(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(Border.class, Border.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlBorderRight(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(Border.class, Border.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlBorderTop(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(Border.class, Border.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlContent(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {

		if (d.size() == 1 && genericOneIdent(Content.class, d, properties))
			return true;
		
		TermList list = tf.createList();
		for (Term<?> t : d.asList()) {
			if (t instanceof TermString)
				list.add(t);
			else
				return false;
		}
		if (list.isEmpty())
			return false;

		properties.put("content", Content.list_values);
		values.put("content", list);
		return true;
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlDisplay(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdent(Display.class, d, properties);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlListStyleType(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(ListStyleType.class, ListStyleType.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlMarginBottom(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Margin.class, Margin.integer, true,
				d, properties, values);
	}

	@SuppressWarnings("unused")
	private boolean processBrlMarginLeft(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Margin.class, Margin.integer, false,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlMarginRight(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Margin.class, Margin.integer, false,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlMarginTop(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Margin.class, Margin.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlPaddingBottom(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Padding.class, Padding.integer, true,
				d, properties, values);
	}

	@SuppressWarnings("unused")
	private boolean processBrlPaddingLeft(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Padding.class, Padding.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlPaddingRight(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Padding.class, Padding.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlPaddingTop(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Padding.class, Padding.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlStringSet(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		
		if (d.size() == 1 && genericOneIdent(StringSet.class, d, properties))
			return true;
		
		final Set<String> validTermIdents = new HashSet<String>(Arrays.asList("print-page"));
		final Set<String> validFuncNames = new HashSet<String>(Arrays.asList("content", "attr"));
		TermList contentList = tf.createList();
		String stringName = null;
		for (Term<?> t : d.asList()) {
			if (stringName == null) {
				if (t instanceof TermIdent)
					stringName = ((TermIdent)t).getValue();
				else
					return false;
			} else {
				if (t instanceof TermString)
					contentList.add(t);
				else if (t instanceof TermFunction
						&& validFuncNames.contains(((TermFunction)t).getFunctionName().toLowerCase()))
					contentList.add(t);
				else
					return false;
			}
		}
		
		if (contentList.isEmpty())
			return false;

		properties.put("string-set", StringSet.content_list);
		values.put("string-set", tf.createPair(stringName, contentList));
		return true;
	}
	
	@SuppressWarnings("unused")
	private boolean processBrlTextIndent(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(TextIndent.class, TextIndent.integer, false,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processPage(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrIdentifier(Page.class, Page.identifier, true,
				d, properties, values);
	}
	
	/****************************************************************
	 * GENERIC METHODS
	 ****************************************************************/

	private <T extends CSSProperty> boolean genericOneIdentOrDotPattern(
			Class<T> type, T dotPatternIdentification, Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {

		if (d.size() != 1)
			return false;
		
		Term<?> term = d.get(0);
		
		if (genericTermIdent(type, term, ALLOW_INH, d.getProperty(),
				properties))
			return true;
		
		try {
			if (TermIdent.class.isInstance(term)) {
				String propertyName = d.getProperty();
				TermDotPattern value = TermDotPattern.createDotPattern((TermIdent)term);
				properties.put(propertyName, dotPatternIdentification);
				values.put(propertyName, value);
				return true;
			}
		} catch (Exception e) {
		}
		return false;
	}
	
	private <T extends CSSProperty> boolean genericOneIdentOrIdentifier(
			Class<T> type, T identifierIdentification, boolean sanify,
			Declaration d, Map<String, CSSProperty> properties,
			Map<String, Term<?>> values) {

		if (d.size() != 1)
			return false;

		return genericTermIdent(type, d.get(0), ALLOW_INH, d.getProperty(),
				properties)
				|| genericTerm(TermIdent.class, d.get(0), d.getProperty(),
						identifierIdentification, sanify, properties, values);
	}
	
	/****************************************************************
	 * Copied from {@link DeclarationTransformer}
	 ****************************************************************/
	
	// private static final boolean AVOID_INH = true;
	private static final boolean ALLOW_INH = false;
	
	public <T extends CSSProperty> T genericPropertyRaw(Class<T> type,
			Set<T> intersection, TermIdent term) {

		try {
			String name = term.getValue().replace("-", "_").toUpperCase();
			T property = CSSProperty.Translator.valueOf(type, name);
			if (intersection != null && intersection.contains(property))
				return property;
			return property;
		} catch (Exception e) {
			return null;
		}
	}
	private <T extends CSSProperty> boolean genericProperty(Class<T> type,
			TermIdent term, boolean avoidInherit,
			Map<String, CSSProperty> properties, String propertyName) {

		T property = genericPropertyRaw(type, null, term);
		if (property == null || (avoidInherit && property.equalsInherit()))
			return false;

		properties.put(propertyName, property);
		return true;
	}
	
	private <T extends CSSProperty> boolean genericTermIdent(Class<T> type,
			Term<?> term, boolean avoidInherit, String propertyName,
			Map<String, CSSProperty> properties) {

		if (term instanceof TermIdent) {
			return genericProperty(type, (TermIdent) term, avoidInherit,
					properties, propertyName);
		}
		return false;
	}
	
	private <T extends CSSProperty> boolean genericTerm(
			Class<? extends Term<?>> termType, Term<?> term,
			String propertyName, T typeIdentification, boolean sanify,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {

		if (termType.isInstance(term)) {
			if (sanify) {
				if (term.getValue() instanceof Integer) {
					final Integer zero = new Integer(0);
					if (zero.compareTo((Integer) term.getValue()) > 0) {
						((TermInteger) term).setValue(zero);
					}
				}
				else if (term.getValue() instanceof Float) {
					final Float zero = new Float(0.0f);
					if (zero.compareTo((Float) term.getValue()) > 0) {
						((TermNumber) term).setValue(zero);
					}
				}
			}
			properties.put(propertyName, typeIdentification);
			values.put(propertyName, term);
			return true;
		}
		return false;
	}
	
	private <T extends CSSProperty> boolean genericOneIdent(Class<T> type,
			Declaration d, Map<String, CSSProperty> properties) {

		if (d.size() != 1)
			return false;

		return genericTermIdent(type, d.get(0), ALLOW_INH, d.getProperty(),
				properties);
	}
	
	private <T extends CSSProperty> boolean genericOneIdentOrInteger(
			Class<T> type, T integerIdentification, boolean sanify,
			Declaration d, Map<String, CSSProperty> properties,
			Map<String, Term<?>> values) {

		if (d.size() != 1)
			return false;

		return genericTermIdent(type, d.get(0), ALLOW_INH, d.getProperty(),
				properties)
				|| genericTerm(TermInteger.class, d.get(0), d.getProperty(),
						integerIdentification, sanify, properties, values);
	}
}
