lexer grammar BrailleCSSLexer;

import CSSLexer;

@header {package org.daisy.braille.css;}

@members {
    public void init() {
        gCSSLexer.init();
    }
    
    @Override
    public Token emit() {
        Token t = gCSSLexer.tf.make();
        emit(t);
        return t;
    }
}

DUMMY: '@@dummy@@' ;
