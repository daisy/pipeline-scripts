package org.daisy.pipeline.braille.common;

public interface XProcCSSBlockTransform extends CSSBlockTransform, XProcTransform {
	
	public interface Provider extends XProcTransform.Provider<XProcCSSBlockTransform> {}
	
}
