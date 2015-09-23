<?xml version="1.0" encoding="UTF-8"?>
<p:library version="1.0"
           xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:dotify="http://code.google.com/p/dotify/">
    
    <p:declare-step type="dotify:xml-to-obfl">
        <p:input port="source" sequence="false"/>
        <p:output port="result" sequence="false"/>
        <p:option name="locale" required="true"/>
        <p:option name="format" required="false" select="'obfl'"/>
        
        <!-- Query syntax -->
        <p:option name="dotify-options" required="false"/>

		<!-- Options (that can also be set using query syntax) -->
        <p:option name="template" required="false" select="'default'"/>
        <p:option name="rows" required="false" select="29"/>
        <p:option name="cols" required="false" select="28"/>
        <p:option name="inner-margin" required="false" select="2"/>
        <p:option name="outer-margin" required="false" select="2"/>
        <p:option name="rowgap" required="false" select="0"/>
        <p:option name="splitterMax" required="false" select="50"/>
    </p:declare-step>
    
</p:library>
