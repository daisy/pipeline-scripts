<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="louis:format" name="format"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:d="http://www.daisy.org/ns/pipeline/data"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:louis="http://liblouis.org/liblouis"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:pef="http://www.daisy.org/ns/2008/pef"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-inline-prefixes="d px pxi c louis pef xsl"
    version="1.0">
    
    <p:input port="source" sequence="true" primary="true"/>
    <p:output port="result" sequence="false" primary="true"/>
    
    <p:option name="temp-dir" required="true"/>
    
    <p:import href="utils/xslt-for-each.xpl"/>
    <p:import href="utils/extract.xpl"/>
    <p:import href="utils/select-by-base.xpl"/>
    <p:import href="split-into-sections.xpl"/>
    <p:import href="attach-liblouis-config.xpl"/>
    <p:import href="translate-files.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/utilities/validate-braille.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/liblouis-calabash/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-calabash/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/pef-utils/xproc/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/file-utils/xproc/file-library.xpl"/>
    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:variable name="pef-table" select="'org.daisy.pipeline.braille.liblouis.pef.LiblouisTableProvider.TableType.NABCC_8DOT'">
        <p:empty/>
    </p:variable>
    
    <px:mkdir>
        <p:with-option name="href" select="$temp-dir"/>
    </px:mkdir>
    
    <p:for-each>
        <p:iteration-source>
            <p:pipe step="format" port="source"/>
        </p:iteration-source>
        <px:validate-braille fail-if-invalid="true"/>
    </p:for-each>
    <p:sink/>
    
    <p:for-each>
        <p:iteration-source>
            <p:pipe step="format" port="source"/>
        </p:iteration-source>
        <p:add-xml-base/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="2.0">
                        <xsl:template match="/*">
                            <xsl:copy>
                                <xsl:copy-of select="document('')/*/namespace::*[name()='louis']"/>
                                <xsl:copy-of select="document('')/*/namespace::*[name()='css']"/>
                                <xsl:sequence select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each name="handle-css-before-after">
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/handle-css-before-after.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each name="handle-css-page">
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/handle-css-page.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each>
        <p:xslt>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="2.0">
                        <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css/xslt/parsing-helper.xsl"/>
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="@style">
                            <xsl:variable name="main-declarations"
                                          select="css:get-declarations(css:tokenize-stylesheet(string(.)), ())"/>
                            <xsl:if test="normalize-space(string($main-declarations))!=''">
                                <xsl:attribute name="style" select="$main-declarations"/>
                            </xsl:if>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each name="handle-css-string-set">
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/handle-css-string-set.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each name="handle-css-display-none">
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/handle-css-display-none.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <pxi:xslt-for-each name="handle-css-toc-item">
        <p:input port="stylesheet">
            <p:document href="../xslt/handle-css-toc-item.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </pxi:xslt-for-each>
    
    <p:for-each name="handle-css-counter-reset">
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/handle-css-counter-reset.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each name="split-into-sections">
        <p:output port="result" sequence="true" primary="true">
            <p:pipe step="split-volume" port="result"/>
        </p:output>
        <p:output port="spine">
            <p:pipe step="spine" port="result"/>
        </p:output>
        <p:group name="split-volume">
            <p:output port="result" sequence="true" primary="true">
                <p:pipe step="sections" port="result"/>
            </p:output>
            <p:output port="spine">
                <p:pipe step="volume-spine" port="result"/>
            </p:output>
            <pxi:split-into-sections/>
            <p:for-each name="sections">
                <p:output port="result"/>
                <p:variable name="i" select="p:iteration-position()"/>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="concat(replace(base-uri(/*),'.xml$',''),'/section_', $i,'.xml')"/>
                </p:add-attribute>
            </p:for-each>
            <p:for-each>
                <p:add-attribute match="/*" attribute-name="href">
                    <p:input port="source">
                        <p:inline>
                            <louis:section/>
                        </p:inline>
                    </p:input>
                    <p:with-option name="attribute-value" select="base-uri(/*)"/>
                </p:add-attribute>
            </p:for-each>
            <p:wrap-sequence wrapper="louis:volume" name="volume-spine"/>
        </p:group>
        <p:wrap-sequence wrapper="louis:spine" name="spine">
            <p:input port="source">
                <p:pipe step="split-volume" port="spine"/>
            </p:input>
        </p:wrap-sequence>
    </p:for-each>
    
    <p:for-each name="attach-liblouis-page-layout">
        <p:xslt name="liblouis-page-layout">
            <p:input port="stylesheet">
                <p:document href="../xslt/generate-liblouis-page-layout.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:insert match="/*" position="last-child">
            <p:input port="source">
                <p:pipe step="attach-liblouis-page-layout" port="current"/>
            </p:input>
            <p:input port="insertion">
                <p:pipe step="liblouis-page-layout" port="result"/>
            </p:input>
        </p:insert>
        <p:delete match="/*/@css:page"/>
    </p:for-each>
    
    <p:for-each name="handle-css-box-model">
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/handle-css-box-model.xsl"/>
            </p:input>
            <p:input port="parameters" select="/*/louis:page-layout/c:param-set">
                <p:pipe step="handle-css-box-model" port="current"/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each name="normalize-css">
        <p:xslt>
            <p:input port="stylesheet">
                <p:document href="../xslt/normalize-css.xsl"/>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
    </p:for-each>
    
    <p:for-each name="extract-box">
        <p:output port="result" sequence="true" primary="true"/>
        <p:output port="extracted" sequence="true">
            <p:pipe step="extract" port="extracted"/>
        </p:output>
        <pxi:extract name="extract" match="louis:box" label="concat('box_', $p:index)"/>
    </p:for-each>
    
    <pxi:xslt-for-each name="group-toc-items">
        <p:input port="iteration-source">
            <p:pipe step="extract-box" port="extracted"/>
            <p:pipe step="extract-box" port="result"/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="../xslt/group-toc-items.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </pxi:xslt-for-each>
    
    <p:for-each name="extract-toc">
        <p:output port="result" sequence="true" primary="true"/>
        <p:output port="extracted" sequence="true">
            <p:pipe step="extract" port="extracted"/>
        </p:output>
        <pxi:extract name="extract" match="louis:toc" label="concat('toc_', $p:index)"/>
    </p:for-each>
    
    <pxi:attach-liblouis-config name="attach-liblouis-config">
        <p:input port="source">
            <p:pipe step="extract-toc" port="extracted"/>
            <p:pipe step="extract-toc" port="result"/>
        </p:input>
        <p:with-option name="directory" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </pxi:attach-liblouis-config>
    
    <pxi:translate-files name="translate-files">
        <p:input port="temp-result.valid">
            <p:empty/>
        </p:input>
        <p:input port="temp-result.invalid">
            <p:empty/>
        </p:input>
        <p:input port="spine">
            <p:pipe step="split-into-sections" port="spine"/>
        </p:input>
        <p:with-option name="temp-dir" select="$temp-dir">
            <p:empty/>
        </p:with-option>
    </pxi:translate-files>
    
    <p:for-each>
        <p:iteration-source select="//louis:section">
            <p:pipe step="split-into-sections" port="spine"/>
        </p:iteration-source>
        <pxi:select-by-base name="select-result">
            <p:input port="source">
                <p:pipe step="translate-files" port="result"/>
            </p:input>
            <p:with-option name="base" select="/*/@href"/>
        </pxi:select-by-base>
        <pef:text2pef>
            <p:with-option name="table" select="$pef-table"/>
            <p:with-option name="temp-dir" select="$temp-dir"/>
        </pef:text2pef>
        <p:add-attribute match="/pef:pef/pef:body/pef:volume" attribute-name="cols">
            <p:with-option name="attribute-value" select="/louis:result/@cols">
                <p:pipe step="select-result" port="matched"/>
            </p:with-option>
        </p:add-attribute>
        <p:add-attribute match="/pef:pef/pef:body/pef:volume" attribute-name="rows">
            <p:with-option name="attribute-value" select="/louis:result/@rows">
                <p:pipe step="select-result" port="matched"/>
            </p:with-option>
        </p:add-attribute>
    </p:for-each>
    
    <pef:merge>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </pef:merge>
    
</p:declare-step>
