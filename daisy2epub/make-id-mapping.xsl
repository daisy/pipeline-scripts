<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:c="http://www.w3.org/ns/xproc-step" exclude-result-prefixes="#all" version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/c:manifest">
        <c:mapping>
            <xsl:apply-templates select="*"/>
        </c:mapping>
    </xsl:template>

    <xsl:template match="c:entry[parent::c:manifest]">
        <c:entry
            content-href="{replace((descendant::text/@src)[1]/tokenize(.,'#')[1],'.[^\.]+$','.xhtml')}"
            original-content-href="{(descendant::text/@src)[1]/tokenize(.,'#')[1]}"
            smil-href="{@href}">
            <xsl:for-each select="descendant::text[@src and @id]">
                <c:id content-id="{tokenize(@src,'#')[last()]}"
                    smil-id="{replace(@id,'^mo\d+_','')}" media-overlay-id="{@id}"/>
            </xsl:for-each>
        </c:entry>
    </xsl:template>

</xsl:stylesheet>
