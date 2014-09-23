<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:split-into-sections"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                exclude-inline-prefixes="p pxi xsl"
                version="1.0">
    
    <!--
        Turn @css:counter-reset="braille-page ..." into @obfl:initial-page-number, split before
        and after @css:page and before @obfl:initial-page-number, and move @css:page and
        @obfl:initial-page-number to css:root.
    -->
    
    <p:input port="source"/>
    <p:output port="result" sequence="true"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="*[@css:counter-entry or @css:counter-reset]">
                        <xsl:copy>
                            <xsl:sequence select="@* except (@css:counter-entry|@css:counter-reset)"/>
                            <xsl:variable name="pairs" as="element()*"
                                          select="(css:parse-counter-reset(@css:counter-entry),
                                                   css:parse-counter-reset(@css:counter-reset))"/>
                            <xsl:if test="$pairs[@identifier!='braille-page']">
                                <xsl:message>counter-reset only supported for braille-page</xsl:message>
                            </xsl:if>
                            <xsl:if test="$pairs[@identifier='braille-page']">
                                <xsl:attribute name="obfl:initial-page-number"
                                               select="$pairs[@identifier='braille-page'][last()]/@value"/>
                            </xsl:if>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <css:split split-before="*[@css:page or @obfl:initial-page-number]" split-after="*[@css:page]"/>
    
    <p:split-sequence test="//css:box"/>
    
    <p:for-each>
        <p:label-elements match="/css:root[descendant::*/@css:page]" attribute="css:page"
                          label="(descendant::*/@css:page)[last()]"/>
        <p:label-elements match="/css:root[descendant::*[not(@part=('middle','last'))]/@obfl:initial-page-number]"
                          attribute="obfl:initial-page-number"
                          label="(descendant::*[not(@part=('middle','last'))]/@obfl:initial-page-number)[last()]"/>
        <p:delete match="/css:root//*/@css:page"/>
        <p:delete match="/css:root//*/@obfl:initial-page-number"/>
        <p:unwrap match="css:_[not(@*)]"/>
    </p:for-each>
    
</p:declare-step>
