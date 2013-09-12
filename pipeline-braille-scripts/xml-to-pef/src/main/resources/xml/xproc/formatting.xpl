<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="#all"
    type="pxi:formatting" name="formatting" version="1.0">
    
    <p:input port="source" primary="true"/>
    <p:output port="result" primary="true" px:media-type="application/x-pef+xml"/>
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-utils/xproc/library.xpl"/>
    
    <louis:format>
        <p:with-option name="temp-dir" select="$temp-dir"/>
    </louis:format>
    
</p:declare-step>
