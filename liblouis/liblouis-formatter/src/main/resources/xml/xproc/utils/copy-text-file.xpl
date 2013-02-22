<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:copy-text-file" name="copy-text-file"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-inline-prefixes="#all"
    version="1.0">
    
    <p:option name="href" required="true"/>
    <p:option name="target" required="true"/>
    
    <p:add-attribute match="/text/xi:include" attribute-name="href">
        <p:input port="source">
            <p:inline><text><xi:include href="?" parse="text"/></text></p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="$href"/>
    </p:add-attribute>
    
    <p:xinclude/>
    
    <p:store method="text">
        <p:with-option name="href" select="$target"/>
    </p:store>
    
</p:declare-step>
