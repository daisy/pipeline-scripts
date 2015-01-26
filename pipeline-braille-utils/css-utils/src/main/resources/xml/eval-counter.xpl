<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:eval-counter"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Evaluate counter() and target-counter() values according to
        http://snaekobbi.github.io/braille-css-spec/#h4_printing-counters-the-counter-function /
        http://snaekobbi.github.io/braille-css-spec/#h4_the-target-counter-function.
    </p:documentation>
    
    <p:input port="source" sequence="true">
        <p:documentation>
            counter() and target-counter() values in the input must be represented by css:counter
            elements. The 'counter-set', 'counter-reset' and 'counter-increment' properties of
            elements must be declared in css:counter-set, css:counter-reset and
            css:counter-increment attributes and must conform to
            http://snaekobbi.github.io/braille-css-spec/#h4_manipulating-counters-the-counter-increment-counter-set-and-counter-reset-properties.
            Elements that are referenced by a target-counter() value must be indicated with a css:id
            attribute that matches the css:counter element's target attribute.
        </p:documentation>
    </p:input>
    
    <p:option name="counters" select="'#all'">
        <p:documentation>
            The 'counters' option must be a space separated list of counter names, or the word
            '#all'.
        </p:documentation>
    </p:option>
    
    <p:option name="exclude-counters" select="''">
        <p:documentation>
            The 'exclude-counters' option must be a space separated list of counter names, or the
            empty string. The option is ignored if the 'counters' option is also specified (and has
            a value other than '#all').
        </p:documentation>
    </p:option>
    
    <p:output port="result" sequence="true">
        <p:documentation>
            For each css:counter element whose counter name is specified in the 'counters' option,
            or not specified in the 'exclude-counters' option if the 'counters' option is '#all',
            the counter value is computed and the counter representation for that value and the
            specified counter style is inserted in place of the css:counter element.
        </p:documentation>
    </p:output>
    
    <p:import href="parse-counter-set.xpl"/>
    
    <p:for-each>
        <css:parse-counter-set>
            <p:with-option name="counters" select="$counters"/>
            <p:with-option name="exclude-counters" select="$exclude-counters"/>
        </css:parse-counter-set>
    </p:for-each>
    
    <p:wrap-sequence wrapper="_"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="eval-counter.xsl"/>
        </p:input>
        <p:with-param name="counter-names" select="$counters"/>
        <p:with-param name="exclude-counter-names" select="$exclude-counters"/>
    </p:xslt>
    
    <p:filter select="/_/*"/>
    
</p:declare-step>
