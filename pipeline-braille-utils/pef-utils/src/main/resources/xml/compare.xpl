<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pef:compare" name="main"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-inline-prefixes="#all"
    version="1.0">

    <p:input port="source" primary="true" px:media-type="application/x-pef+xml"/>
    <p:input port="alternate" px:media-type="application/x-pef+xml"/>
    <p:output port="result" primary="false" sequence="false">
        <p:pipe step="compare" port="result"/>
    </p:output>
    
    <p:option name="fail-if-not-equal" select="'false'"/>
    
    <p:declare-step type="pxi:normalize-pef">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:delete match="/*/pef:head/pef:meta/dc:date"/>
        <p:delete match="/*/pef:head/pef:meta/dc:identifier"/>
        <p:string-replace match="text()" replace="replace(normalize-space(.), '&#x2800;+$', '')"/>
        <p:delete match="//pef:row[string(.)='' and not(following-sibling::pef:row[string(.)!=''])]"/>
    </p:declare-step>
    
    <pxi:normalize-pef name="normalize-source">
        <p:input port="source">
            <p:pipe step="main" port="source"/>
        </p:input>
    </pxi:normalize-pef>
    
    <pxi:normalize-pef name="normalize-alternate">
        <p:input port="source">
            <p:pipe step="main" port="alternate"/>
        </p:input>
    </pxi:normalize-pef>
    
    <p:compare name="compare">
        <p:input port="source">
            <p:pipe step="normalize-source" port="result"/>
        </p:input>
        <p:input port="alternate">
            <p:pipe step="normalize-alternate" port="result"/>
        </p:input>
        <p:with-option name="fail-if-not-equal" select="$fail-if-not-equal"/>
    </p:compare>
    
</p:declare-step>
