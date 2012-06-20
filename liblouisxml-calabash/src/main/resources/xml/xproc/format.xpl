<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="lblxml:format" name="format"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    exclude-inline-prefixes="lblxml px p"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="create-liblouisxml-files.xpl"/>
    <p:import href="format-toc.xpl"/>
    <p:import href="xml2brl.xpl"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/handle-list-item.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/handle-border.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="../xslt/handle-toc.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:xslt name="create-styles-xml">
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/create-styles-xml.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:add-attribute attribute-name="xml:base" match="/*" name="temp-directory">
        <p:input port="source">
            <p:inline>
                <c:directory/>
            </p:inline>
        </p:input>
        <p:with-option name="attribute-value" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </p:add-attribute>
    
    <lblxml:create-liblouisxml-files name="create-liblouisxml-files">
        <p:input port="source">
            <p:pipe step="create-styles-xml" port="result"/>
        </p:input>
        <p:input port="styles">
            <p:pipe step="create-styles-xml" port="secondary"/>
        </p:input>
        <p:input port="directory">
            <p:pipe step="temp-directory" port="result"/>
        </p:input>
    </lblxml:create-liblouisxml-files>
    
    <lblxml:format-toc name="format-toc">
        <p:input port="source">
            <p:pipe step="create-styles-xml" port="result"/>
        </p:input>
        <p:input port="toc-styles">
            <p:pipe step="create-styles-xml" port="secondary"/>
        </p:input>
        <p:input port="config-files">
            <p:pipe step="create-liblouisxml-files" port="config"/>
        </p:input>
        <p:input port="semantic-files">
            <p:pipe step="create-liblouisxml-files" port="semantic"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </lblxml:format-toc>
    
    <lblxml:xml2brl name="xml2brl">
        <p:input port="source">
            <p:pipe step="format-toc" port="result"/>
        </p:input>
        <p:input port="config-files">
            <p:pipe step="create-liblouisxml-files" port="config"/>
        </p:input>
        <p:input port="semantic-files">
            <p:pipe step="create-liblouisxml-files" port="semantic"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </lblxml:xml2brl>
    
</p:declare-step>
