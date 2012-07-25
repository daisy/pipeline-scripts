<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:update-toc" name="update-toc"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:louis="http://liblouis.org/liblouis"
    version="1.0">
    
    <p:input port="source" sequence="false" primary="true"/>
    <p:input port="config-files" sequence="true"/>
    <p:input port="semantic-files" sequence="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/liblouis-calabash/xproc/library.xpl"/>
    
    <p:viewport match="//*[child::louis:toc]" name="update">
        
        <p:split-sequence name="config-files">
            <p:input port="source">
                <p:pipe step="update-toc" port="config-files"/>
            </p:input>
            <p:with-option name="test" select="concat('position()=', p:iteration-position())">
                <p:empty/>
            </p:with-option>
        </p:split-sequence>
        
        <p:split-sequence name="semantic-files">
            <p:input port="source">
                <p:pipe step="update-toc" port="semantic-files"/>
            </p:input>
            <p:with-option name="test" select="concat('position()=', p:iteration-position())">
                <p:empty/>
            </p:with-option>
        </p:split-sequence>
            
        <p:xslt>
            <p:input port="source">
                <p:pipe step="update-toc" port="source"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/select-toc.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:with-param name="select" select="p:iteration-position()">
                <p:empty/>
            </p:with-param>
        </p:xslt>
            
        <louis:translate-file name="xml2brl">
            <p:input port="config-files">
                <p:pipe step="config-files" port="matched"/>
            </p:input>
            <p:input port="semantic-files">
                <p:pipe step="semantic-files" port="matched"/>
            </p:input>
            <!-- FIXME this is a very ugly solution -->
            <p:with-option name="ini-file"
                select="concat(substring(base-uri(/), 0, string-length(base-uri(/))-19), 'lbx_files/liblouisutdml.ini')">
                <p:document href="format.xpl"/>
            </p:with-option>
            <p:with-option name="temp-dir" select="$temp-dir">
                <p:empty/>
            </p:with-option>
        </louis:translate-file>
            
        <p:xslt name="preformatted-toc">
            <p:input port="source" select="/louis:output/louis:section[1]">
                <p:pipe step="xml2brl" port="result"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/read-liblouis-output.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        
        <p:delete match="louis:preformatted">
            <p:input port="source">
                <p:pipe step="update" port="current"/>
            </p:input>
        </p:delete>
        
        <p:insert match="louis:toc" position="after">
            <p:input port="insertion">
                <p:pipe step="preformatted-toc" port="result"/>
            </p:input>
        </p:insert>
    </p:viewport>
    
    <p:group>
        
        <p:variable name="old-toc-lengths"
            select="count(//louis:toc/following-sibling::louis:preformatted/louis:line)">
            <p:pipe step="update-toc" port="source"/>
        </p:variable>
        
        <p:variable name="new-toc-lengths"
            select="count(//louis:toc/following-sibling::louis:preformatted/louis:line)">
            <p:pipe step="update" port="result"/>
        </p:variable> 
        
        <p:choose>
            <p:when test="$new-toc-lengths &gt; $old-toc-lengths">
                <louis:update-toc>
                    <p:input port="source">
                        <p:pipe step="update" port="result"/>
                    </p:input>
                    <p:input port="config-files">
                        <p:pipe step="update-toc" port="config-files"/>
                    </p:input>
                    <p:input port="semantic-files">
                        <p:pipe step="update-toc" port="semantic-files"/>
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
    </p:group>
    
</p:declare-step>
