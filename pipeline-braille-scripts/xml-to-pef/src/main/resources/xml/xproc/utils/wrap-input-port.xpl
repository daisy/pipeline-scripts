<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    exclude-inline-prefixes="#all"
    type="pxi:wrap-input-port" version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:output port="result" primary="true"/>
    <p:option name="port" required="true"/>
    
    <p:wrap match="/*" wrapper="cx:document"/>
    
    <p:add-attribute match="/*" attribute-name="port">
        <p:with-option name="attribute-value" select="$port">
            <p:empty/>
        </p:with-option>
    </p:add-attribute>
    
</p:declare-step>
