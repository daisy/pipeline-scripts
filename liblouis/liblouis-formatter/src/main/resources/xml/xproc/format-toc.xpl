<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:format-toc" name="format-toc"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:input port="source-toc" sequence="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="true" primary="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-calabash/xproc/library.xpl"/>
    
    <p:variable name="liblouis-table"
        select="'http://www.daisy.org/pipeline/modules/braille/liblouis-formatter/tables/nabcc.dis,braille-patterns.cti,pagenum.cti'">
        <p:empty/>
    </p:variable>
    
    <!-- Generate toc -->
    
    <p:for-each name="generate-toc">
        <p:iteration-source>
            <p:pipe step="format-toc" port="source-toc"/>
        </p:iteration-source>
        <p:output port="result" sequence="true" primary="true"/>
        <p:variable name="toc-base" select="base-uri(/*/*[1])"/>
        <p:variable name="toc-id" select="/*/*[1]/@xml:id"/>
        <p:split-sequence>
            <p:input port="source">
                <p:pipe step="format-toc" port="source"/>
            </p:input>
            <p:with-option name="test" select="concat('/*/*[1]/@xml:base = &quot;', $toc-base, '&quot;')">
                <p:empty/>
            </p:with-option>
        </p:split-sequence>
        <p:insert match="/*/*[1]" position="first-child" name="ref-document">
            <p:input port="insertion">
                <p:inline>
                    <louis:no-pagenum>
                        <louis:toc>&#xA0;</louis:toc>
                    </louis:no-pagenum>
                </p:inline>
            </p:input>
        </p:insert>
        <p:xslt name="mark-toc-items">
            <p:input port="source" select="/*/*[1]">
                <p:pipe step="ref-document" port="result"/>
                <p:pipe step="generate-toc" port="current"/>
            </p:input>
            <p:input port="stylesheet">
                <p:document href="../xslt/mark-toc-items.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <louis:translate-file name="translate-file">
            <p:input port="source">
                <p:pipe step="mark-toc-items" port="result"/>
            </p:input>
            <p:input port="styles" select="/*/*[2]">
                <p:pipe step="ref-document" port="result"/>
                <p:pipe step="generate-toc" port="current"/>
            </p:input>
            <p:input port="semantics" select="/*/*[3]">
                <p:pipe step="ref-document" port="result"/>
                <p:pipe step="generate-toc" port="current"/>
            </p:input>
            <p:input port="page-layout" select="/*/*[4]">
                <p:pipe step="ref-document" port="result"/>
            </p:input>
            <p:with-option name="table" select="$liblouis-table"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </louis:translate-file>
        <p:xslt>
            <p:input port="source" select="/louis:output/louis:section[1]"/>
            <p:input port="stylesheet">
                <p:document href="../xslt/read-liblouis-output.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
            <p:with-param name="crop-top" select="1">
                <p:empty/>
            </p:with-param>
            <p:with-param name="crop-left" select="/*/louis:toc/@margin-right">
                <p:pipe step="generate-toc" port="current"/>
            </p:with-param>
        </p:xslt>
        <p:rename match="/*" new-name="louis:include"/>
        <p:add-attribute attribute-name="ref" match="/*">
            <p:with-option name="attribute-value" select="$toc-id"/>
        </p:add-attribute>
    </p:for-each>
    
    <!-- Insert toc -->
    
    <p:for-each name="insert-toc">
        <p:iteration-source>
            <p:pipe step="format-toc" port="source"/>
        </p:iteration-source>
        <p:output port="result" primary="true"/>
        <p:viewport match="//louis:include">
            <p:variable name="toc-id" select="/*/@ref"/>
            <p:split-sequence>
                <p:input port="source">
                    <p:pipe step="generate-toc" port="result"/>
                </p:input>
                <p:with-option name="test" select="concat('/*/@ref = &quot;', $toc-id, '&quot;')"/>
            </p:split-sequence>
        </p:viewport>
    </p:for-each>
    
    <!-- Decide whether to do another pass -->
    
    <p:wrap-sequence wrapper="tocs" name="old-tocs">
        <p:input port="source" select="//louis:include">
            <p:pipe step="format-toc" port="source"/>
        </p:input>
    </p:wrap-sequence>
    <p:sink/>
    <p:wrap-sequence wrapper="tocs" name="new-tocs">
        <p:input port="source" select="//louis:include">
            <p:pipe step="insert-toc" port="result"/>
        </p:input>
    </p:wrap-sequence>
    <p:sink/>
    <p:group>
        <p:variable name="old-toc-lengths" select="count(//louis:line)">
            <p:pipe step="old-tocs" port="result"/>
        </p:variable>
        <p:variable name="new-toc-lengths" select="count(//louis:line)">
            <p:pipe step="new-tocs" port="result"/>
        </p:variable> 
        <p:choose>
            <p:when test="$new-toc-lengths &gt; $old-toc-lengths">
                <pxi:format-toc>
                    <p:input port="source">
                        <p:pipe step="insert-toc" port="result"/>
                    </p:input>
                    <p:input port="source-toc">
                        <p:pipe step="format-toc" port="source-toc"/>
                    </p:input>
                    <p:with-option name="temp-dir" select="$temp-dir"/>
                </pxi:format-toc>
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:input port="source">
                        <p:pipe step="insert-toc" port="result"/>
                    </p:input>
                </p:identity>
            </p:otherwise>
        </p:choose>
    </p:group>
    
</p:declare-step>
