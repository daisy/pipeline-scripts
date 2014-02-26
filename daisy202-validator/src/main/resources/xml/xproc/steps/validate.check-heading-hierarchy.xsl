<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0" xmlns:html="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:d="http://www.daisy.org/ns/pipeline/data">

    <xsl:template match="/*">
        <xsl:variable name="base-uri" select="base-uri(/*)"/>
        <d:messages>
            <xsl:for-each select="//*[matches(local-name(),'h\d')]">
                <xsl:variable name="level" select="number(substring(local-name(),2))"/>
                <xsl:variable name="preceding-level" select="number(substring((preceding::*[matches(local-name(),'h\d')])[1]/local-name(),2))"/>
                <xsl:if test="$level - 1 &gt; $preceding-level">
                    <d:message severity="error">
                        <d:desc>incorrect heading hierarchy at <xsl:value-of select="concat('/',string-join(for $e in (ancestor-or-self::*) return concat($e/name(),'[',(count($e/preceding-sibling::*[name()=$e/name()])+1),']'),'/'))"
                            /></d:desc>
                        <d:file>
                            <xsl:value-of select="$base-uri"/>
                        </d:file>
                        <d:was>h<xsl:value-of select="$level"/></d:was>
                        <d:expected>h<xsl:value-of select="$preceding-level+1"/> or less</d:expected>
                    </d:message>
                </xsl:if>
            </xsl:for-each>
        </d:messages>
    </xsl:template>

</xsl:stylesheet>
