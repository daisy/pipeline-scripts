<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    exclude-result-prefixes="#all" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:mo="http://www.w3.org/ns/SMIL">
    <xsl:param name="xml-base" required="yes"/>
    <xsl:template match="/*">
        <d:fileset xml:base="{$xml-base}">
            <xsl:for-each select="distinct-values(//mo:text/@src/tokenize(.,'#')[1])">
                <d:file href="{.}" media-type="application/xhtml+xml"/>
            </xsl:for-each>
        </d:fileset>
    </xsl:template>
</xsl:stylesheet>
