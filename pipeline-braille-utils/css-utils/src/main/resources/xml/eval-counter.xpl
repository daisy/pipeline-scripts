<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:eval-counter"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    
    <p:option name="counters" select="'#all'"/>
    <p:option name="exclude-counters" select="''"/>
    
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
