<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
    xmlns:louis="http://liblouis.org/liblouis"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:include href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xsl"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:block[child::css:target-text and
                                   not(child::text()[normalize-space(.)!='']) and
                                   not(child::*[not(self::css:target-text or
                                                    self::css:target-string[@identifier='print-page'] or
                                                    self::css:target-counter[@identifier='braille-page'] or
                                                    self::css:leader)])]">
        <xsl:variable name="target" as="xs:string*"
                      select="distinct-values(child::*[not(self::css:leader)]/string(@target))"/>
        <xsl:choose>
            <xsl:when test="count($target)=1 and $target[1]!='' and
                            collection()/*[not(self::louis:box)]
                                        //*[@xml:id=$target[1] or concat('#',@xml:id)=$target[1]]">
                <xsl:element name="louis:toc-item">
                    <xsl:attribute name="ref" select="replace($target[1],'^#','')"/>
                    <xsl:sequence select="@style|@css:display"/>
                    <xsl:if test="count(css:leader)=1">
                        <xsl:attribute name="leader" select="css:leader/@pattern"/>
                    </xsl:if>
                    <xsl:if test="count(css:target-string[@identifier='print-page'])=1">
                        <xsl:attribute name="print-page" select="'true'"/>
                    </xsl:if>
                    <xsl:if test="count(css:target-counter[@identifier='braille-page'])=1">
                        <xsl:attribute name="braille-page" select="'true'"/>
                    </xsl:if>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        backup for text references that could not be turned into a louis:toc-item
    -->
    <xsl:template match="css:target-text">
        <xsl:variable name="target" as="xs:string" select="string(@target)"/>
        <xsl:copy>
            <xsl:value-of select="string(collection()//*[@xml:id=$target or concat('#',@xml:id)=$target])"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="css:target-string[@identifier='print-page']">
        <xsl:variable name="target" as="xs:string" select="string(@target)"/>
        <xsl:copy>
            <xsl:value-of select="string(collection()//*[@xml:id=$target or concat('#',@xml:id)=$target]
                                                     /preceding::louis:print-page[1])"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
