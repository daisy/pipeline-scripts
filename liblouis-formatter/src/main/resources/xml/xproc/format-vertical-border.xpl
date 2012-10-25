<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:format-vertical-border" name="format-vertical-border"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-inline-prefixes="louis"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-calabash/xproc/library.xpl"/>
    
    <p:variable name="liblouis-ini-file"
        select="concat(substring(base-uri(/), 0, string-length(base-uri(/))-19), 'lbx_files/liblouisutdml.ini')">
        <p:document href="format.xpl"/>
    </p:variable>
    <p:variable name="liblouis-table"
        select="'http://www.daisy.org/pipeline/modules/braille/liblouis-formatter/tables/nabcc.dis,braille-patterns.cti,pagenum.cti'"/>
    
    <p:viewport match="louis:vertical-border" name="format">
        
        <p:rename match="/*">
            <p:with-option name="new-name" select="name(/*/*[1])">
                <p:pipe step="format-vertical-border" port="source"/>
            </p:with-option>
            <p:with-option name="new-namespace" select="namespace-uri(/*/*[1])">
                <p:pipe step="format-vertical-border" port="source"/>
            </p:with-option>
        </p:rename>
        
        <p:delete match="/*/@*"/>
        
        <p:insert match="/*" position="first-child">
            <p:input port="insertion">
                <p:inline>
                    <louis:preformatted>
                        <louis:line>&#xA0;</louis:line>
                    </louis:preformatted>
                </p:inline>
            </p:input>
        </p:insert>
        
        <p:insert match="/*" position="last-child">
            <p:input port="insertion">
                <p:inline>
                    <louis:preformatted>
                        <louis:line>&#xA0;</louis:line>
                    </louis:preformatted>
                </p:inline>
            </p:input>
        </p:insert>
        
        <louis:translate-file paged="false">
            <p:input port="styles" select="/*/*[2]">
                <p:pipe step="format-vertical-border" port="source"/>
            </p:input>
            <p:input port="semantics" select="/*/*[3]">
                <p:pipe step="format-vertical-border" port="source"/>
            </p:input>
            <p:with-param port="page-layout" name="page-width" select="/*/@width">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-option name="ini-file" select="$liblouis-ini-file"/>
            <p:with-option name="table" select="$liblouis-table"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </louis:translate-file>
        
        <p:xslt name="preformatted">
            <p:input port="stylesheet">
                <p:document href="../xslt/read-liblouis-output.xsl"/>
            </p:input>
            <p:with-param name="width" select="/*/@width">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-param name="margin-left" select="/*/@margin-left">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-param name="border-left" select="/*/@border-left">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-param name="border-right" select="/*/@border-right">
                <p:pipe step="format" port="current"/>
            </p:with-param>
            <p:with-param name="keep-empty-trailing-lines" select="'true'">
                <p:empty/>
            </p:with-param>
            <p:with-param name="crop-top" select="1">
                <p:empty/>
            </p:with-param>
            <p:with-param name="crop-bottom" select="1">
                <p:empty/>
            </p:with-param>
        </p:xslt>
    </p:viewport>
    
</p:declare-step>
