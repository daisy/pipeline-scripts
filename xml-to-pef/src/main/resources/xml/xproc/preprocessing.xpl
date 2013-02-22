<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    exclude-inline-prefixes="#all"
    type="pxi:preprocessing" name="preprocessing" version="1.0">

    <p:input port="source" primary="true"/>
    <p:input port="preprocessors" sequence="true"/>
    <p:output port="result" primary="true"/>
    
    <p:import href="utils/eval-steps.xpl"/>
    
    <pxi:eval-steps>
        <p:input port="steps">
            <p:pipe step="preprocessing" port="preprocessors"/>
        </p:input>
    </pxi:eval-steps>
    
</p:declare-step>
