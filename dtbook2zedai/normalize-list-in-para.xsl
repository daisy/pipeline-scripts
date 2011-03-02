<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0">
    
    <xsl:import href="normalize-generic-moveout.xsl"/>
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:param name="invalid-parents-A" select="'p'"/>
    
    <xsl:param name="invalid-parents-B"></xsl:param>
    
    <xsl:param name="alternative" select="'na'"/>
    
    <xsl:param name="target-element" select="'list'"/>
    
    <xsl:param name="valid-parents" select="tokenize('annotation,prodnote,sidebar,address,covertitle,div,epigraph,imggroup,caption,code,
        kbd,li,note,img,blockquote,level,level1,level2,level3,level4,level5,level6,td,th', ',')"/>
    
    <xsl:template match="/">
        
        <xsl:message>normalize-list-in-para</xsl:message>
        <xsl:call-template name="test-and-move">
            <xsl:with-param name="doc" select="//dtb:dtbook[1]"/>
        </xsl:call-template>
        
    </xsl:template>       
    
</xsl:stylesheet>
