<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd" version="2.0">

    <xsl:output indent="yes" method="xml"/>

    <!-- create MODS output from dtb:* metadata-->
    <mods xmlns="http://www.loc.gov/mods/v3" version="3.3">

        <xsl:template match="//head">

            <!-- if there are any dtb:source* metadata properties, then create the relatedItem element -->
            <xsl:if test="./meta[contains(@property, 'dtb:source')]">
                <relatedItem type="original">

                    <xsl:if test="./meta[@property = 'dtb:sourceRights']">
                        <accessCondition>
                            <xsl:value-of select="@content"/>
                        </accessCondition>
                    </xsl:if>

                    <xsl:if test="./meta[@property = 'dtb:sourceTitle']">
                        <titleInfo>
                            <title>
                                <xsl:value-of select="@content"/>
                            </title>
                        </titleInfo>
                    </xsl:if>

                    <xsl:if
                        test="./meta[@property = 'dtb:sourceDate'] or ./meta[@property = 'dtb:sourceEdition'] or 
                           ./meta[@property = 'dtb:sourcePublisher']">
                        <originInfo>

                            <xsl:if test="./meta[@property = 'dtb:sourceDate']">
                                <dateIssued><xsl:value-of select="@content"/></dateIssued>
                            </xsl:if>
                            <xsl:if test="./meta[@property = 'dtb:sourceEdition']">
                                <edition><xsl:value-of select="@content"/></edition>
                            </xsl:if>
                            <xsl:if test="./meta[@property = 'dtb:sourcePublisher']">
                                <publisher><xsl:value-of select="@content"/></publisher>
                            </xsl:if>
                            
                        </originInfo>
                    </xsl:if>

                </relatedItem>
            </xsl:if>

            <!-- if there are any dtb:produce* metadata properties, then create the originInfo element -->
            <xsl:if test="./meta[contains(@property, 'dtb:producer') or ./meta[contains(@property, 'dtb:producedDate')">
                <originInfo>
                    <xsl:if test="./meta[contains(@property, 'dtb:producer')">
                        <publisher><xsl:value-of select="@content"/></publisher>
                    </xsl:if>
                    <xsl:if test="./meta[contains(@property, 'dtb:producedDate')">
                        <dateCreated><xsl:value-of select="@content"/></dateCreated>
                    </xsl:if>
                </originInfo>
            </xsl:if>
        </xsl:template>
    </mods>


</xsl:stylesheet>
