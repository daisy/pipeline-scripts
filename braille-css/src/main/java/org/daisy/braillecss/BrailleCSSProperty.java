package org.daisy.braillecss;

import cz.vutbr.web.css.CSSProperty;

public interface BrailleCSSProperty extends CSSProperty {

	/************************************************************************
	 * BRAILLE CSS PROPERTIES *
	 ************************************************************************/

	public enum Border implements BrailleCSSProperty {
		dot_pattern(""), NONE("none"), INHERIT("inherit");

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

	public enum Display implements BrailleCSSProperty {
		INLINE("inline"), BLOCK("block"), LIST_ITEM("list-item"), TOC("toc"), 
		TOC_TITLE("toc-title"), TOC_ITEM("toc-item"), NONE("none"), INHERIT("inherit");

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
		dot_pattern(""), NONE("none"), INHERIT("inherit");

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
		integer(""), INHERIT("inherit");

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
		integer(""), INHERIT("inherit");

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
