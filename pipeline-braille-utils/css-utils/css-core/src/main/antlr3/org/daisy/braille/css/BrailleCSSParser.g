parser grammar BrailleCSSParser;

options {
    output = AST;
    tokenVocab=BrailleCSSLexer;
    k = 2;
}

import CSSParser;

@header {package org.daisy.braille.css;}

@members {
    public void init() {
        gCSSParser.init();
    }
}

dummy : DUMMY ;
