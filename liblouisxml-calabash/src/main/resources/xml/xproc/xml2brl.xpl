<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="lblxml:xml2brl"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:input port="config-files" sequence="false"/>
    <p:input port="semantic-files" sequence="false"/>
    <p:option name="paged" required="false"/>
    <p:option name="page-height" required="false"/>
    <p:option name="line-width" required="false"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
</p:declare-step>
