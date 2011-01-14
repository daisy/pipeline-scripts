<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0">
    
    <xd:doc>
        <xd:desc>This stylesheet maps some elements with dtbook:inline content model to something that will translate easily into zedai.</xd:desc>
    </xd:doc>
    
    
    <xsl:output indent="yes" method="xml"/>
    
    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- TODO: there are many dtbook elements whose content model is x + inline.  could process them here too. -->
    
    <xsl:template match="dtb:title | dtb:author | dtb:byline | dtb:dateline | dtb:em | dtb:strong | dtb:bdo | dtb:span | dtb:q | 
    dtb:doctitle | dtb:docauthor | dtb:h1 | dtb:h2 | dtb:h3 | dtb:h4 | dtb:h5 | dtb:h6 | dtb:bridgehead | dtb:hd">
        <xsl:call-template name="normalize-inline"/>
    </xsl:template>
    
    <!-- TODO: double check that dtb:p makes sense here -->
    <xsl:template match="dtb:p">
        <xsl:call-template name="normalize-inline"/>
    </xsl:template>
    
   
    <!-- all of these elements have a dtbook:inline content model.  we need to move some child nodes to make it compatible with content model of the elements' zedai representation -->
    <!--        
        The question is, though, can all possible parents of zedai:h have zedai:block and zedai:separator as children too?
        
        For zedai:h the answer is: yes, if we deal separately with poetry (section-verse and verse elements)
        
        TODO: Now just to check for all the others ... 
        
        TODO: the element-splitting won't work for all cases.  for example, h1 should not be split into many h1s because only one at a time is allowed.
    -->
    
    <xsl:template name="normalize-inline">
        
        <!-- save the parent element -->
        <xsl:variable name="elem" select="."/>
        
            <xsl:choose>
                <xsl:when test="./dtb:imggroup">
                    
                    <!-- move imggroup -->
                    <xsl:for-each-group select="*|text()[normalize-space()]" group-adjacent="boolean(self::dtb:imggroup)">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key()">
                                <xsl:element name="imggroup" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                    <xsl:apply-templates select="@*"/>
                                    <xsl:apply-templates/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-- split the parent element -->
                                <xsl:element name="{name($elem)}" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                    <xsl:apply-templates select="$elem/@*"/>
                                    <xsl:apply-templates select="current-group()"/>
                                </xsl:element>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                        
                    </xsl:for-each-group>
                    
                </xsl:when>
                <xsl:when test="./dtb:samp">
                    
                </xsl:when>
                <xsl:when test="./dtb:br">
                    
                </xsl:when>
                <xsl:otherwise>
                    
                    <xsl:element name="{name($elem)}" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                        <xsl:apply-templates select="@*"/>
                        <xsl:apply-templates/>                        
                    </xsl:element>
                    
                </xsl:otherwise>
            </xsl:choose>
            
        
    </xsl:template>
    
    
</xsl:stylesheet>
