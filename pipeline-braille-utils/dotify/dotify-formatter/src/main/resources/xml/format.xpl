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
    
    <p:import href="css-to-obfl.xpl"/>
    <p:import href="obfl-normalize-space.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/dotify-calabash/library.xpl"/>
    
    <pxi:css-to-obfl name="obfl"/>
    
    <pxi:obfl-normalize-space/>
    <dotify:obfl-to-pef locale="und" mode="dotify:format"/>
    
</p:declare-step>
