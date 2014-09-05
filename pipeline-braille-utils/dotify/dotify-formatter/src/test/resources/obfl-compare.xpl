<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:obfl-compare" name="main"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:x="http://www.daisy.org/ns/xprocspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                version="1.0">
    
    <p:input port="context" primary="false"/>
    <p:input port="expect" primary="false"/>
    <p:input port="parameters" kind="parameter" primary="true"/>
    
    <p:output port="result" primary="true"/>

    <p:declare-step type="pxi:normalize-obfl">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:xslt>
            <p:input port="stylesheet">
                <p:inline>
                    <xsl:stylesheet version="2.0">
                        <xsl:variable name="layout_names" as="xs:string*" select="/obfl:obfl/obfl:layout-master/@name/string()"/>
                        <xsl:template match="@*|node()">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:template>
                        <xsl:template match="obfl:layout-master/@name">
                            <xsl:attribute name="name" select="concat('layout',index-of($layout_names,string(.)))"/>
                        </xsl:template>
                        <xsl:template match="obfl:sequence/@master">
                            <xsl:attribute name="master" select="concat('layout',index-of($layout_names,string(.)))"/>
                        </xsl:template>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
            <p:input port="parameters">
                <p:empty/>
            </p:input>
        </p:xslt>
        <p:delete match="/*/@xml:space"/>
        <p:string-replace match="text()" replace="normalize-space(.)"/>
    </p:declare-step>
    
    <pxi:normalize-obfl name="normalize-context">
        <p:input port="source">
            <p:pipe step="main" port="context"/>
        </p:input>
    </pxi:normalize-obfl>
    
    <pxi:normalize-obfl name="normalize-expect">
        <p:input port="source">
            <p:pipe step="main" port="expect"/>
        </p:input>
    </pxi:normalize-obfl>
    
    <p:compare fail-if-not-equal="false" name="compare">
        <p:input port="source">
            <p:pipe step="normalize-context" port="result"/>
        </p:input>
        <p:input port="alternate">
            <p:pipe step="normalize-expect" port="result"/>
        </p:input>
    </p:compare>
    
    <p:rename match="/*" new-name="x:test-result">
        <p:input port="source">
            <p:pipe port="result" step="compare"/>
        </p:input>
    </p:rename>
    
    <p:add-attribute match="/*" attribute-name="result">
        <p:with-option name="attribute-value" select="if (string(/*)='true') then 'passed' else 'failed'">
            <p:pipe port="result" step="compare"/>
        </p:with-option>
    </p:add-attribute>
    
    <p:delete match="/*/node()" name="result"/>
    
    <p:choose>
        <p:when test="/*/@result='passed'">
            <p:identity/>
        </p:when>
        <p:otherwise>
            <p:wrap-sequence wrapper="x:expected" name="expected">
                <p:input port="source">
                    <p:pipe step="main" port="expect"/>
                </p:input>
            </p:wrap-sequence>
            <p:wrap-sequence wrapper="x:was" name="was">
                <p:input port="source">
                    <p:pipe step="main" port="context"/>
                </p:input>
            </p:wrap-sequence>
            <p:insert match="/*" position="last-child">
                <p:input port="source">
                    <p:pipe step="result" port="result"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe port="result" step="expected"/>
                    <p:pipe port="result" step="was"/>
                </p:input>
            </p:insert>
            <p:add-attribute match="/*/*" attribute-name="xml:space" attribute-value="preserve"/>
        </p:otherwise>
    </p:choose>
    
</p:declare-step>
