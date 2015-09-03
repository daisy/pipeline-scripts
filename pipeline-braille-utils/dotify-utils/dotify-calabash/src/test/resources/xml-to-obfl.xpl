<?xml version="1.0" encoding="UTF-8"?>
<p:library version="1.0"
           xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:dotify="http://code.google.com/p/dotify/">
    
    <p:declare-step type="dotify:xml-to-obfl">
        <p:input port="source" sequence="false"/>
        <p:output port="result" sequence="false"/>
        <p:option name="locale" required="true"/>
    </p:declare-step>
    
</p:library>
