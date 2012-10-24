<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:translate-file"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:input port="styles" sequence="true"/>
    <p:input port="semantics" sequence="true"/>
    <p:option name="ini-file" required="true"/>
    <p:option name="table" required="true"/>
    <p:option name="paged" required="false" select="'true'"/>
    <p:option name="page-height" required="false"/>
    <p:option name="page-width" required="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
</p:declare-step>
