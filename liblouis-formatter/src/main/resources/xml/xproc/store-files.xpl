<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:store-files" name="store-files"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="louis px p"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="directory" sequence="false"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    
    <p:for-each name="files">
        <p:output port="result"/>
        <px:tempfile delete-on-exit="false" name="tempfile">
            <p:with-option name="href" select="/c:directory/@xml:base">
                <p:pipe step="store-files" port="directory"/>
            </p:with-option>
        </px:tempfile>
        <p:store method="text">
            <p:input port="source">
                <p:pipe step="files" port="current"/>
            </p:input>
            <p:with-option name="href" select="/c:result">
                <p:pipe step="tempfile" port="result"/>
            </p:with-option>
        </p:store>
        <p:add-attribute match="/*" attribute-name="name">
            <p:input port="source">
                <p:inline>
                    <c:file/>
                </p:inline>
            </p:input>
            <p:with-option name="attribute-value" select="replace(/c:result, '^.*/', '')">
                <p:pipe step="tempfile" port="result"/>
            </p:with-option>
        </p:add-attribute>
    </p:for-each>
    
    <p:insert match="/c:directory" position="last-child">
        <p:input port="source">
            <p:pipe step="store-files" port="directory"/>
        </p:input>
        <p:input port="insertion">
            <p:pipe step="files" port="result"/>
        </p:input>
    </p:insert>
    
</p:declare-step>
