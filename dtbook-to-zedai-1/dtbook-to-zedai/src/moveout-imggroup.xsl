<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    exclude-result-prefixes="dtb" version="2.0">
    
    <xsl:include href="moveout-generic.xsl"/>
    
    <xsl:output indent="yes" method="xml"/>
    
    <xsl:template match="/">
        <xsl:call-template name="main">
            <xsl:with-param name="document" select="//dtb:dtbook[1]"/>
        </xsl:call-template>
    </xsl:template>
        
    <xsl:template name="main">
        <xsl:param name="document"/>
        <xsl:message>Move out image groups</xsl:message>
        <xsl:call-template name="test-and-move">
            <!--<xsl:with-param name="doc" select="$document"/>-->
            <xsl:with-param name="root-elem" select="if ($document instance of document-node()) then $document/*[1] else $document"/>
            <xsl:with-param name="target-elem-name" select="'imggroup'" tunnel="yes"/>
            <xsl:with-param name="valid-parents-list" select="tokenize('annotation-block,prodnote,sidebar,address,covertitle,div,epigraph,imggroup,caption,code-block,kbd,li,note,img,blockquote,level,level1,level2,level3,level4,level5,level6,td,th,poem,samp', ',')"  tunnel="yes"/>
            
        </xsl:call-template>
        <xsl:message>--Done</xsl:message>
        
    </xsl:template>       
    
</xsl:stylesheet>
