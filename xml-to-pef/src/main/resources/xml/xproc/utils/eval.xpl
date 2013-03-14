<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="pxi:eval" name="eval" version="1.0">
    
    <p:input port="pipeline"/>
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="options" kind="parameter"/>
    <p:output port="result"/>
    
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="options.xpl"/>
    
    <pxi:options name="options">
        <p:input port="options">
            <p:pipe step="eval" port="options"/>
        </p:input>
    </pxi:options>
    
    <cx:eval>
        <p:input port="source">
            <p:pipe step="eval" port="source"/>
        </p:input>
        <p:input port="pipeline">
            <p:pipe step="eval" port="pipeline"/>
        </p:input>
        <p:input port="options">
            <p:pipe step="options" port="result"/>
        </p:input>
    </cx:eval>
    
</p:declare-step>
