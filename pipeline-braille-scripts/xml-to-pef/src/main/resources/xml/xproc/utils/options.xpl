<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="pxi:options" name="options" version="1.0">
    
    <p:input port="options" kind="parameter" primary="false"/>
    <p:output port="result" primary="false">
        <p:pipe step="result" port="result"/>
    </p:output>
    
    <p:parameters name="parameters">
        <p:input port="parameters">
            <p:pipe step="options" port="options"/>
        </p:input>
    </p:parameters>
    
    <p:rename match="c:param-set" new-name="cx:options">
        <p:input port="source">
            <p:pipe step="parameters" port="result"/>
        </p:input>
    </p:rename>
    
    <p:rename match="c:param" new-name="cx:option" name="result"/>
    
</p:declare-step>
