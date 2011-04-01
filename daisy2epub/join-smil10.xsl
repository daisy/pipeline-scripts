<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:px="http://pipeline.daisy.org/ns/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="2.0">

    <xsl:import href="smil-library.xsl"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/*">
        <smil>
            <xsl:variable name="timeInThisSmil" select="sum(//body/seq/px:clockValToSeconds(@dur))"/>
            <head>
                <meta name="ncc:timeInThisSmil"
                    content="{px:secondsToFullClockVal($timeInThisSmil)}"
                    skip-content="{if (//head/meta[@name='ncc:timeInThisSmil']/@skip-content) then (//head/meta[@name='ncc:timeInThisSmil'])[1]/@skip-content else 'true'}"/>

                <xsl:if test="//head/meta[@name='title']">
                    <meta name="title"
                        content="{string-join(distinct-values(//head/meta[@name='title']/@content),', ')}"
                        skip-content="{if (//head/meta[@name='title']/@skip-content) then (//head/meta[@name='title'])[1]/@skip-content else 'true'}"
                    />
                </xsl:if>

                <xsl:copy-of select="(//head/layout)[1]"/>

                <xsl:for-each
                    select="//head/meta[not(@name=preceding::meta/@name)
                                        and not(@name='ncc:timeInThisSmil')
                                        and not(@name='title')]">
                    <xsl:copy>
                        <xsl:apply-templates select="@*|node()"/>
                    </xsl:copy>
                </xsl:for-each>
            </head>
            <body>
                <seq dur="{px:secondsToTimecount($timeInThisSmil)}"
                    repeat="{if (//body/seq/@repeat) then (//body/seq)[1]/@repeat else '1'}">
                    <xsl:for-each select="//body/*">
                        <par>
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </par>
                    </xsl:for-each>
                </seq>
            </body>
        </smil>
    </xsl:template>

</xsl:stylesheet>
