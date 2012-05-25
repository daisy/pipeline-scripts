<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="lblxml:format" name="format"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>    
    <p:option name="temp-dir" required="true" px:type="anyDirURI"/>    
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
    
    <p:xslt name="create-automatic-styles">
        <p:input port="stylesheet">
            <p:document href="http://www.daisy.org/pipeline/modules/braille-formatting-utils/xslt/create-automatic-styles.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <lblxml:create-liblouisxml-files name="create-liblouisxml-files">
        <p:input port="styles">
            <p:pipe step="create-automatic-styles" port="secondary"/>
        </p:input>
    </lblxml:create-liblouisxml-files>
    
    <lblxml:format-toc name="format-toc">
        <p:input port="source">
            <p:pipe step="create-automatic-styles" port="result"/>
        </p:input>
        <p:input port="toc-styles">
            <p:pipe step="create-automatic-styles" port="secondary"/>
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
