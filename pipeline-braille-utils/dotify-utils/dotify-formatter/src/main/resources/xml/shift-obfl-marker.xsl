<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:template match="/*">
        <!-- first pass: move markers -->
        <xsl:variable name="move-markers" as="document-node()">
            <xsl:document>
                <xsl:call-template name="move-markers"/>
            </xsl:document>
        </xsl:variable>
        
        <!-- second pass: remove @pxi:forward-markers attributes -->
        <xsl:apply-templates select="$move-markers" mode="remove-pxi"/>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="remove-pxi">
        <xsl:copy>
            <xsl:apply-templates select="@* except @pxi:*" mode="#current"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template name="move-markers">
        <xsl:param name="forward-markers" as="xs:string*"/>
        
        <!-- determine if we should forward or keep the marker(s) -->
        <xsl:variable name="should-forward" select="not(ancestor-or-self::css:box/@type='inline')"/>
        <xsl:variable name="forward-markers" select="if ($should-forward) then ($forward-markers, @css:_obfl-marker/tokenize(., '\s+')) else $forward-markers"/>
        
        <!-- determine if we should create/update a marker attribute -->
        <xsl:variable name="marker" select="if (self::css:box[@type='inline']) then string-join($forward-markers,' ') else ''"/>
        <xsl:variable name="forward-markers" select="if ($marker) then '' else $forward-markers"/>
        
        <!-- recursively handle descendants -->
        <xsl:variable name="descendants" as="node()*">
            <xsl:choose>
                <xsl:when test="*">
                    <xsl:for-each select="*[1]">
                        <xsl:call-template name="move-markers">
                            <xsl:with-param name="forward-markers" select="$forward-markers"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="forward-markers" select="if (*) then $descendants[self::*][last()]/tokenize(@pxi:forward-markers,' ') else $forward-markers"/>
        
        <!-- preceding non-element nodes -->
        <xsl:if test="not(preceding-sibling::*)">
            <xsl:copy-of select="preceding-sibling::node()"/>
        </xsl:if>
        
        <xsl:copy>
            <xsl:copy-of select="@* except @css:_obfl-marker"/>
            
            <!-- marker -->
            <xsl:choose>
                <xsl:when test="$marker">
                    <xsl:attribute name="css:_obfl-marker" select="$marker"/>
                </xsl:when>
                <xsl:when test="not($should-forward)">
                    <xsl:copy-of select="@css:_obfl-marker"/>
                </xsl:when>
            </xsl:choose>
            
            <!-- if there are no more following siblings to forward markers to; bubble up the markers to the parent -->
            <xsl:if test="count($forward-markers) and not(following-sibling::*)">
                <xsl:attribute name="pxi:forward-markers" select="string-join($forward-markers,' ')"/>
            </xsl:if>
            
            <!-- descendant nodes -->
            <xsl:copy-of select="$descendants"/>
            
        </xsl:copy>
        
        <!-- trailing non-element nodes -->
        <xsl:copy-of select="following-sibling::node() intersect following-sibling::*[1]/preceding-sibling::node()"/>
        <xsl:if test="not(following-sibling::*)">
            <xsl:copy-of select="following-sibling::node()"/>
        </xsl:if>
        
        <!-- recursively handle following siblings -->
        <xsl:for-each select="following-sibling::*[1]">
            <xsl:call-template name="move-markers">
                <xsl:with-param name="forward-markers" select="$forward-markers"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
