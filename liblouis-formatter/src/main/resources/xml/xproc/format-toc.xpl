<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:format-toc" name="format-toc"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:input port="toc-styles" sequence="false"/>
    <p:input port="config-files" sequence="false"/>
    <p:input port="semantic-files" sequence="false"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="update-toc.xpl"/>
    <p:import href="store-files.xpl"/>
    
    <p:choose>
        <p:when test="//louis:toc">
            
            <p:for-each name="config-files">
                <p:iteration-source select="//louis:toc">
                    <p:pipe step="format-toc" port="source"/>
                </p:iteration-source>
                <p:output port="result"/>
                <p:xslt>
                    <p:input port="source">
                        <p:pipe step="format-toc" port="toc-styles"/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:document href="../xslt/create-toc-styles-cfg-file.xsl"/>
                    </p:input>
                    <p:with-param name="toc-item-styles" select="distinct-values(.//*[@css:toc-item]/@louis:style)">
                        <p:pipe step="config-files" port="current"/>
                    </p:with-param>
                </p:xslt>
                <louis:store-files>
                    <p:input port="directory">
                        <p:pipe step="format-toc" port="config-files"/>
                    </p:input>
                </louis:store-files>
            </p:for-each>
            
            <p:for-each name="semantic-files">
                <p:iteration-source select="//louis:toc">
                    <p:pipe step="format-toc" port="source"/>
                </p:iteration-source>
                <p:output port="result"/>
                <p:xslt template-name="initial">
                    <p:input port="stylesheet">
                        <p:document href="../xslt/create-toc-styles-sem-file.xsl"/>
                    </p:input>
                    <p:with-param name="toc-item-styles" select="distinct-values(.//*[@css:toc-item]/@louis:style)">
                        <p:pipe step="semantic-files" port="current"/>
                    </p:with-param>
                </p:xslt>
                <louis:store-files>
                    <p:input port="directory">
                        <p:pipe step="format-toc" port="semantic-files"/>
                    </p:input>
                </louis:store-files>
            </p:for-each>
            
            <louis:update-toc>
                <p:input port="source">
                    <p:pipe step="format-toc" port="source"/>
                </p:input>
                <p:input port="config-files">
                    <p:pipe step="config-files" port="result"/>
                </p:input>
                <p:input port="semantic-files">
                    <p:pipe step="semantic-files" port="result"/>
                </p:input>
                <p:with-option name="temp-dir" select="$temp-dir">
                    <p:empty/>
                </p:with-option>
            </louis:update-toc>
        </p:when>
        
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
