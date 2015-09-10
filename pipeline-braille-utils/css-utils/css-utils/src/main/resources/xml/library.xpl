<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
           xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
           version="1.0">
    
    <p:declare-step type="css:inline">
        <p:input port="source" sequence="false" primary="true"/>
        <p:output port="result" sequence="false" primary="true"/>
        <p:option name="default-stylesheet" required="false"/>
    </p:declare-step>
    
    <p:import href="adjust-boxes.xpl"/>
    <p:import href="eval-counter.xpl"/>
    <p:import href="eval-string-set.xpl"/>
    <p:import href="eval-target-text.xpl"/>
    <p:import href="label-targets.xpl"/>
    <p:import href="make-anonymous-block-boxes.xpl"/>
    <p:import href="make-anonymous-inline-boxes.xpl"/>
    <p:import href="make-boxes.xpl"/>
    <p:import href="make-pseudo-elements.xpl"/>
    <p:import href="new-definition.xpl"/>
    <p:import href="padding-to-margin.xpl"/>
    <p:import href="parse-content.xpl"/>
    <p:import href="parse-counter-set.xpl"/>
    <p:import href="parse-properties.xpl"/>
    <p:import href="parse-stylesheet.xpl"/>
    <p:import href="preserve-white-space.xpl"/>
    <p:import href="repeat-string-set.xpl"/>
    <p:import href="shift-id.xpl"/>
    <p:import href="shift-string-set.xpl"/>
    <p:import href="split.xpl"/>
    
</p:library>