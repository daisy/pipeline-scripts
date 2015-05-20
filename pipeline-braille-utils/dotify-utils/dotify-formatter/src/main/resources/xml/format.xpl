<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="dotify:format"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:dotify="http://code.google.com/p/dotify/"
                version="1.0">
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    <p:output port="obfl" sequence="false">
        <p:pipe step="obfl" port="result"/>
    </p:output>
    
    <p:option name="text-transform" select="'auto'"/>
    
    <p:import href="css-to-obfl.xpl"/>
    <p:import href="obfl-normalize-space.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/dotify-utils/library.xpl"/>
    
    <pxi:css-to-obfl name="obfl">
        <p:with-option name="text-transform" select="$text-transform"/>
    </pxi:css-to-obfl>
    
    <pxi:obfl-normalize-space/>
    
    <dotify:obfl-to-pef locale="und">
        <p:with-option name="mode" select="concat('dotify:format ',$text-transform)"/>
    </dotify:obfl-to-pef>
    
</p:declare-step>
