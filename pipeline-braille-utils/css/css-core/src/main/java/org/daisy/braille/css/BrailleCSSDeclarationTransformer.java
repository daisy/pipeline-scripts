package org.daisy.braille.css;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

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

import cz.vutbr.web.css.CSSFactory;
import cz.vutbr.web.css.CSSProperty;
import cz.vutbr.web.css.Declaration;
import cz.vutbr.web.css.SupportedCSS;
import cz.vutbr.web.css.Term;
import cz.vutbr.web.css.TermFunction;
import cz.vutbr.web.css.TermIdent;
import cz.vutbr.web.css.TermInteger;
import cz.vutbr.web.css.TermList;
import cz.vutbr.web.css.TermString;
import cz.vutbr.web.domassign.DeclarationTransformer;
import cz.vutbr.web.domassign.Repeater;

public class BrailleCSSDeclarationTransformer extends DeclarationTransformer {
	
	private final SupportedCSS css;
	private final Map<String,Method> methods;
	
	public BrailleCSSDeclarationTransformer() {
		super();
		css = CSSFactory.getSupportedCSS();
		methods = new HashMap<String,Method>();
		for (String property : css.getDefinedPropertyNames()) {
			try {
				Method method = BrailleCSSDeclarationTransformer.class.getDeclaredMethod(
					camelCase("process-" + property),
					Declaration.class, Map.class, Map.class);
				methods.put(property, method);
			} catch (Exception e) {
			}
		}
	}
	
	@Override
	public boolean parseDeclaration(Declaration d, Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		String property = d.getProperty().toLowerCase();
		if (!css.isSupportedCSSProperty(property)) {
			return false;
		}
		try {
			Method m = methods.get(property);
			if (m != null)
				return (Boolean)m.invoke(this, d, properties, values);
			else
				return super.parseDeclaration(d, properties, values);
		} catch (Exception e) {
		}
		return false;
	}
	
	/****************************************************************
	 * PROCESSING METHODS
	 ****************************************************************/
	
	@SuppressWarnings("unused")
	private boolean processBorderBottom(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(Border.class, Border.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBorderLeft(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(Border.class, Border.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBorderRight(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(Border.class, Border.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBorderTop(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(Border.class, Border.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processBorder(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		Repeater r = new BorderRepeater();
		return r.repeatOverFourTermDeclaration(d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processContent(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {

		if (d.size() == 1 && genericOneIdent(Content.class, d, properties))
			return true;
		
		final Set<String> validFuncNames = new HashSet<String>(Arrays.asList(
				"content", "attr", "target-text", "target-string", "target-counter", "leader"));
		
		TermList list = tf.createList();
		for (Term<?> t : d.asList()) {
			if (t instanceof TermString)
				list.add(t);
			else if (t instanceof TermFunction
			         && validFuncNames.contains(((TermFunction)t).getFunctionName().toLowerCase()))
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
	private boolean processDisplay(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdent(Display.class, d, properties);
	}
	
	@SuppressWarnings("unused")
	private boolean processLeft(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(AbsoluteMargin.class, AbsoluteMargin.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processListStyleType(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrDotPattern(ListStyleType.class, ListStyleType.dot_pattern,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processMarginBottom(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Margin.class, Margin.integer, true,
				d, properties, values);
	}

	@SuppressWarnings("unused")
	private boolean processMarginLeft(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Margin.class, Margin.integer, false,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processMarginRight(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Margin.class, Margin.integer, false,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processMarginTop(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Margin.class, Margin.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processMargin(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		Repeater r = new MarginRepeater();
		return r.repeatOverFourTermDeclaration(d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processPaddingBottom(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Padding.class, Padding.integer, true,
				d, properties, values);
	}

	@SuppressWarnings("unused")
	private boolean processPaddingLeft(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Padding.class, Padding.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processPaddingRight(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Padding.class, Padding.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processPaddingTop(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(Padding.class, Padding.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processPadding(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		Repeater r = new PaddingRepeater();
		return r.repeatOverFourTermDeclaration(d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processPage(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrIdentifier(Page.class, Page.identifier, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processRight(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(AbsoluteMargin.class, AbsoluteMargin.integer, true,
				d, properties, values);
	}
	
	@SuppressWarnings("unused")
	private boolean processStringSet(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		
		if (d.size() == 1 && genericOneIdent(StringSet.class, d, properties))
			return true;
		
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
	private boolean processTextIndent(Declaration d,
			Map<String, CSSProperty> properties, Map<String, Term<?>> values) {
		return genericOneIdentOrInteger(TextIndent.class, TextIndent.integer, false,
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
	 * REPEATER CLASSES
	 ****************************************************************/
	
	private final class BorderRepeater extends Repeater {
			
		public BorderRepeater() {
			super(4);
			type = Border.class;
			names.add("border-top");
			names.add("border-right");
			names.add("border-bottom");
			names.add("border-left");
		}
		
		protected boolean operation(int i,
		                            Map<String,CSSProperty> properties,
		                            Map<String,Term<?>> values) {
			
			Term<?> term = terms.get(i);
			
			if (genericTermIdent(type, term, AVOID_INH, names.get(i), properties))
				return true;
			
			try {
				if (TermIdent.class.isInstance(term)) {
					String propertyName = names.get(i);
					TermDotPattern value = TermDotPattern.createDotPattern((TermIdent)term);
					properties.put(propertyName, Border.dot_pattern);
					values.put(propertyName, value);
					return true;
				}
			} catch (Exception e) {
			}
			return false;
		}
	}
	
	private final class MarginRepeater extends Repeater {

		public MarginRepeater() {
			super(4);
			type = Margin.class;
			names.add("margin-top");
			names.add("margin-right");
			names.add("margin-bottom");
			names.add("margin-left");
		}
		
		protected boolean operation(int i,
		                            Map<String,CSSProperty> properties,
		                            Map<String,Term<?>> values) {
			return genericTermIdent(type, terms.get(i), AVOID_INH, names.get(i), properties)
				|| genericTerm(TermInteger.class, terms.get(i), names.get(i),
				               Margin.integer, false, properties, values);
		}
	}
	
	private final class PaddingRepeater extends Repeater {
			
		public PaddingRepeater() {
			super(4);
			type = Padding.class;
			names.add("padding-top");
			names.add("padding-right");
			names.add("padding-bottom");
			names.add("padding-left");
		}
		
		protected boolean operation(int i,
		                            Map<String,CSSProperty> properties,
		                            Map<String,Term<?>> values) {
			return genericTermIdent(type, terms.get(i), AVOID_INH, names.get(i), properties)
				|| genericTerm(TermInteger.class, terms.get(i), names.get(i),
				               Padding.integer, false, properties, values);
		}
	}
}
