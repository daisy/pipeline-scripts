<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-inline-prefixes="#all"
    type="px:generic-liblouis-translate-mathml" version="1.0">
    
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-mathml/xproc/library.xpl"/>
    
    <p:viewport match="m:math">
        <louis:translate-mathml>
            <p:with-option name="temp-dir" select="$temp-dir"/>
            <p:with-option name="math-code" select="'wiskunde'"/>
        </louis:translate-mathml>
    </p:viewport>
    
</p:pipeline>
