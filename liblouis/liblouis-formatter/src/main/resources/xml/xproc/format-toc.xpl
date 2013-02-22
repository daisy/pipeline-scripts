<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:format-toc" name="format-toc"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    
    xmlns:dbg="http://www.daisy.org/ns/pipeline/xproc/debug"
    
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:option name="temp-dir" required="true"/>
    <p:output port="result" sequence="true" primary="true"/>
    
    <p:import href="utils/select-by-base.xpl"/>
    <p:import href="utils/select-by-position.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-calabash/xproc/library.xpl"/>
    
    <!-- Debug mode -->
    <p:import href="http://www.daisy.org/pipeline/modules/debug-utils/library.xpl"/>
    
    <p:split-sequence name="split-sequence" test="/louis:toc"/>
    
    <!-- Generate toc -->
    
    <p:for-each name="generate-toc">
        <p:iteration-source>
            <p:pipe step="split-sequence" port="matched"/>
        </p:iteration-source>
        <p:output port="result" sequence="true" primary="true"/>
        <pxi:select-by-base name="ref-document">
            <p:input port="source">
                <p:pipe step="split-sequence" port="not-matched"/>
            </p:input>
            <p:with-option name="base" select="resolve-uri(/louis:toc/@href)">
                <p:pipe step="generate-toc" port="current"/>
            </p:with-option>
        </pxi:select-by-base>
        <p:sink/>
        <p:xslt>
            <p:input port="source">
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
        <p:insert match="/*" position="first-child" >
            <p:input port="insertion">
                <p:inline>
                    <louis:no-pagenum>
                        <louis:toc>&#xA0;</louis:toc>
                    </louis:no-pagenum>
                </p:inline>
            </p:input>
        </p:insert>
        <louis:translate-file>
            <p:input port="styles" select="/*/louis:styles/d:fileset">
                <p:pipe step="ref-document" port="result"/>
                <p:pipe step="generate-toc" port="current"/>
            </p:input>
            <p:input port="semantics" select="/*/louis:semantics/d:fileset">
                <p:pipe step="ref-document" port="result"/>
                <p:pipe step="generate-toc" port="current"/>
            </p:input>
            <p:input port="page-layout" select="/*/louis:page-layout/c:param-set">
                <p:pipe step="ref-document" port="result"/>
            </p:input>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </louis:translate-file>
        <pxi:select-by-position position="1"/>
        <p:group>
            <p:variable name="width" select="number(/louis:toc/@width)">
                <p:pipe step="generate-toc" port="current"/>
            </p:variable>
            <p:variable name="page-width" select="number(/*/louis:page-layout//c:param[@name='page-width']/@value)">
                <p:pipe step="ref-document" port="result"/>
            </p:variable>
            <p:xslt>
                <p:input port="stylesheet">
                    <p:document href="../xslt/read-liblouis-result.xsl"/>
                </p:input>
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:with-param name="width" select="$width"/>
                <p:with-param name="crop-top" select="1"/>
                <p:with-param name="crop-left" select="max((0,$page-width - $width))"/>
            </p:xslt>
        </p:group>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="base-uri(/louis:toc)">
                <p:pipe step="generate-toc" port="current"/>
            </p:with-option>
        </p:add-attribute>
    </p:for-each>
    
    <!-- Insert toc -->
    
    <p:for-each name="insert-toc">
        <p:iteration-source>
            <p:pipe step="format-toc" port="source"/>
        </p:iteration-source>
        <p:output port="result" primary="true"/>
        <p:viewport match="//louis:include" name="viewport">
            <pxi:select-by-base name="toc-result">
                <p:input port="source">
                    <p:pipe step="generate-toc" port="result"/>
                </p:input>
                <p:with-option name="base" select="resolve-uri(/*/@href)"/>
            </pxi:select-by-base>
            <p:sink/>
            <p:delete match="/*/*">
                <p:input port="source">
                    <p:pipe step="viewport" port="current"/>
                </p:input>
            </p:delete>
            <p:insert match="/*" position="first-child">
                <p:input port="insertion">
                    <p:pipe step="toc-result" port="result"/>
                </p:input>
            </p:insert>
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
