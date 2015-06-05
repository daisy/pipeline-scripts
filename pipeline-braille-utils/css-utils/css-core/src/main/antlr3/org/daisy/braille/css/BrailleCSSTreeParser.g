tree grammar BrailleCSSTreeParser;

options {
    tokenVocab=BrailleCSSLexer;
    ASTLabelType=CommonTree;
}

import CSSTreeParser;

@header {
package org.daisy.braille.css;
import cz.vutbr.web.css.MediaQuery;
import cz.vutbr.web.css.RuleList;
import cz.vutbr.web.csskit.antlr.Preparator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
}

@members {
    private static Logger log = LoggerFactory.getLogger(BrailleCSSTreeParser.class);
    
    public void init(Preparator preparator, List<MediaQuery> wrapMedia) {
        gCSSTreeParser.init(preparator, wrapMedia);
    }
    
    public RuleList getRules() {
        return gCSSTreeParser.getRules();
    }
    
    public List<List<MediaQuery>> getImportMedia() {
        return gCSSTreeParser.getImportMedia();
    }
    
    public List<String> getImportPaths() {
        return gCSSTreeParser.getImportPaths();
    }
}

dummy returns [Object o]
    : DUMMY
    ;
