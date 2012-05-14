<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="lblxml:create-liblouisxml-files" name="create-liblouisxml-files"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:lblxml="http://xmlcalabash.com/ns/extensions/liblouisxml"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:input port="styles" sequence="true"/>
    
    <p:output port="config" sequence="true" primary="true">
        <p:pipe step="split-liblouisxml-files" port="matched"/>
    </p:output>
    
    <p:output port="semantic" sequence="true">
        <p:pipe step="split-liblouisxml-files" port="not-matched"/>
    </p:output>
    
    <p:xslt name="default-sem">
        <p:input port="stylesheet">
            <p:document href="../xslt/create-default-sem-file.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="create-liblouisxml-files" port="styles"/>
        </p:input>
    </p:identity>
    
    <p:for-each name="styles-cfg">
        <p:output port="result"/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-styles-cfg-file.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:identity>
        <p:input port="source">
            <p:pipe step="create-liblouisxml-files" port="styles"/>
        </p:input>
    </p:identity>
    
    <p:for-each name="styles-sem">
        <p:output port="result"/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/create-styles-sem-file.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:split-sequence test="/lblxml:config-file" name="split-liblouisxml-files">
        <p:input port="source">
            <p:pipe step="default-sem" port="result"/>
            <p:pipe step="styles-cfg" port="result"/>
            <p:pipe step="styles-sem" port="result"/>
        </p:input>
    </p:split-sequence>
    
</p:declare-step>
