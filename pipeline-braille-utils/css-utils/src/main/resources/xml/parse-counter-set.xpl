<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:parse-counter-set"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:input port="source"/>
    <p:output port="result"/>
    
    <p:option name="counters" select="'#all'"/>
    <p:option name="exclude-counters" select="''"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="parse-counter-set.xsl"/>
        </p:input>
        <p:with-param name="counter-names" select="$counters"/>
        <p:with-param name="exclude-counter-names" select="$exclude-counters"/>
    </p:xslt>
        
</p:declare-step>
