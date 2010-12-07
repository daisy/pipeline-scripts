<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0">
    
    <xd:doc>
        <xd:desc>This stylesheet un-nests linegroup and lines without regard to validity.</xd:desc>
    </xd:doc>
    
    <xsl:output indent="yes" method="xml"/>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dtb:line">
        <xsl:call-template name="line">
            <xsl:with-param name="line" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="line">
        <xsl:param name="line" select="."/>
        <xsl:param name="runaway" select="not(ancestor::dtb:linegroup)"/>
        <xsl:choose>
            <!--xsl:when test="ancestor-or-self::dtb:code">
                this is how to ignore parsing of certain elements, don't think it's needed for DTBook?
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when-->
            <xsl:when test="count(descendant::dtb:linegroup)>0 or $runaway">
                <!-- treat this line as a linegroup if it contains other linegroups or is a runaway line (no linegroup parent) -->
                <xsl:call-template name="linegroup"/>
            </xsl:when>
            <xsl:when test="count(descendant::dtb:line)>0">
                <!-- nested line, descend and split into multiple lines -->
                <xsl:for-each-group select="*" group-adjacent="not(descendant-or-self::dtb:line)">
                    <xsl:for-each select="current-group()">
                        <xsl:call-template name="line"/>
                    </xsl:for-each>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:when test="name()='line' or name()='pagenum'">
                <!-- line as line -->
                <xsl:copy>
                    <xsl:apply-templates select="$line/@*"/>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="name($line)='line'">
                        <!-- simple line -->
                        <xsl:copy>
                            <xsl:apply-templates select="$line/@*"/>
                            <xsl:apply-templates/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- non-line as line -->
                        <xsl:if test="not(not(node()) and not(normalize-space(.)))">
                            <line xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:copy>
                                    <xsl:apply-templates select="$line/@*"/>
                                    <xsl:apply-templates/>
                                </xsl:copy>
                            </line>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dtb:linegroup">
        <xsl:call-template name="linegroup">
            <xsl:with-param name="linegroup" select="."/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="linegroup">
        <xsl:param name="linegroup" select="."/>
        <xsl:choose>
            <!--xsl:when test="ancestor-or-self::dtb:code">
                this is how to ignore parsing of certain elements, don't think it's needed for DTBook?
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when-->
            <xsl:when test="descendant::dtb:linegroup">
                <!-- nested linegroup, descend and split into multiple linegroups -->
                <xsl:for-each-group select="*|text()"
                    group-adjacent="not(descendant-or-self::dtb:linegroup)">
                    <xsl:choose>
                        <xsl:when
                            test="not(current-group()/node()) and not(normalize-space(current-group()))"/>
                        <xsl:when test="current-grouping-key()">
                            <linegroup xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:apply-templates select="$linegroup/@*"/>
                                <xsl:for-each select="current-group()">
                                    <xsl:call-template name="line">
                                        <xsl:with-param name="runaway" select="false()"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </linegroup>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="current-group()">
                                <xsl:choose>
                                    <xsl:when test="not(self::dtb:line) and not(self::dtb:linegroup)">
                                        <xsl:copy>
                                            <xsl:apply-templates select="$linegroup/@*"/>
                                            <xsl:call-template name="linegroup"/>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="linegroup"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <!-- no linegroups to un-nest, now fix all lines... -->
                <xsl:choose>
                    <xsl:when test="name($linegroup)='linegroup'">
                        <xsl:copy>
                            <xsl:apply-templates select="$linegroup/@*"/>
                            <xsl:for-each select="./*">
                                <xsl:call-template name="line">
                                    <xsl:with-param name="runaway" select="false()"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="name($linegroup)='line' and count(descendant::dtb:line)>0">
                        <linegroup xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                            <xsl:for-each-group select="*|text()"
                                group-adjacent="not(descendant-or-self::dtb:line)">
                                <xsl:choose>
                                    <xsl:when test="current-grouping-key()">
                                        <line xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                                            <xsl:apply-templates select="$linegroup/@*"/>
                                            <xsl:apply-templates/>
                                        </line>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="current-group()">
                                            <xsl:call-template name="line">
                                                <xsl:with-param name="runaway" select="false()"/>
                                            </xsl:call-template>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each-group>
                        </linegroup>
                    </xsl:when>
                    <xsl:when test="name($linegroup)='line'">
                        <xsl:if test="not(not(node()) and not(normalize-space(.)))">
                            <linegroup xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:copy>
                                    <xsl:apply-templates select="$linegroup/@*"/>
                                    <xsl:apply-templates/>
                                </xsl:copy>
                            </linegroup>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not(not(node()) and not(normalize-space(.)))">
                            <linegroup xmlns="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:apply-templates select="$linegroup/@*"/>
                                <xsl:for-each select="./*">
                                    <xsl:call-template name="line">
                                        <xsl:with-param name="line"/>
                                        <xsl:with-param name="runaway" select="false()"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                            </linegroup>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
