package org.daisy.braille.css;

import cz.vutbr.web.css.CSSProperty;

public interface BrailleCSSProperty extends CSSProperty {

	/************************************************************************
	 * BRAILLE CSS PROPERTIES *
	 ************************************************************************/
	
	public enum AbsoluteMargin implements BrailleCSSProperty {
		integer(""), INHERIT("inherit");

		private String text;

		private AbsoluteMargin(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return true;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}
	
	public enum Border implements BrailleCSSProperty {
		dot_pattern(""), component_values(""), NONE("none"), INHERIT("inherit");

		private String text;

		private Border(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return false;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}

	public enum Content implements BrailleCSSProperty {
		list_values(""), NONE("none"), INHERIT("inherit");

		private String text;

		private Content(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return false;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}
	
		@Override
		public String toString() {
			return text;
		}
	}
	
	public enum Display implements BrailleCSSProperty {
		INLINE("inline"), BLOCK("block"), LIST_ITEM("list-item"),
		NONE("none"), PAGE_BREAK("page-break"), INHERIT("inherit");

		private String text;

		private Display(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return false;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}

	public enum ListStyleType implements BrailleCSSProperty {
		dot_pattern(""), DECIMAL("decimal"), LOWER_ALPHA("lower-alpha"), LOWER_ROMAN("lower-roman"),
		NONE("none"), UPPER_ALPHA("upper-alpha"), UPPER_ROMAN("upper-roman"), INHERIT("inherit");

		private String text;

		private ListStyleType(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return true;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}

	public enum Margin implements BrailleCSSProperty {
		integer(""), component_values(""), INHERIT("inherit");

		private String text;

		private Margin(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return false;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}

	public enum Padding implements BrailleCSSProperty {
		integer(""), component_values(""), INHERIT("inherit");

		private String text;

		private Padding(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return false;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}

	public enum Page implements CSSProperty {
		identifier(""), AUTO("auto"), INHERIT("inherit");

		private String text;

		private Page(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return true;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}
	
	public enum StringSet implements BrailleCSSProperty {
		content_list(""), NONE("none"), INHERIT("inherit");
		
		private String text;

		private StringSet(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return false;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}
	
	public enum TextIndent implements BrailleCSSProperty {
		integer(""), INHERIT("inherit");

		private String text;

		private TextIndent(String text) {
			this.text = text;
		}

		public boolean inherited() {
			return true;
		}

		public boolean equalsInherit() {
			return this == INHERIT;
		}

		@Override
		public String toString() {
			return text;
		}
	}
}
