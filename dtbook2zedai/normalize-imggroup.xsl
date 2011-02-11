<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0"
    xmlns:p2="http://code.google.com/p/daisy-pipeline/">
    <!-- TODO: what's the official namespace for pipeline2? -->

    <xd:doc>
        <xd:desc>Move imggroup out and split the element(s) that used to contain it. Description of
            the issues surrounding this transformation can be found here:
            http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI_imggroup</xd:desc>

    </xd:doc>
    
    <xsl:output indent="yes" method="xml"/>


    <!-- TODO: parametrize this so it can be used for linegroup too -->
    
    <xsl:template match="/">
       
        <xsl:message>start</xsl:message>
        <xsl:call-template name="test-and-move">
            <xsl:with-param name="doc" select="//dtb:dtbook[1]"/>
        </xsl:call-template>

    </xsl:template>

    <!-- recursive -->
    <xsl:template name="test-and-move">
        <xsl:param name="doc"/>
        
        <xsl:choose>
            <xsl:when test="p2:test-valid($doc) = true()">
                <xsl:message>Input is Valid</xsl:message>
                <xsl:copy-of select="$doc"></xsl:copy-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Input is Invalid</xsl:message>

                
                <xsl:variable name="result">
                    <xsl:apply-templates select="$doc"/>
                </xsl:variable>
                
                <!-- the recursive call -->
                <xsl:call-template name="test-and-move">
                    <xsl:with-param name="doc" select="$result//dtb:dtbook[1]"/>
                </xsl:call-template>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- these are invalid imggroup parents that can be split into many instances of themselves -->
    <xsl:variable name="invalid-parents-A"
        select="tokenize('a,abbr,acronym,author,bdo,bridgehead,byline,cite,dateline,dd,dt,dfn,docauthor,doctitle,em,
        line,linegroup,p,q,sent,span,strong,sub,sup,title,w', ',')"/>
    <!-- these are invalid imggroup parents that cannot be split into many instances of themselves -->
    <xsl:variable name="invalid-parents-B" select="tokenize('h1,h2,h3,h4,h5,h6,hd', ',')"/>
    
    
    <xsl:function name="p2:test-valid">
        <xsl:param name="elem"/>
        <xsl:variable name="valid-parents"
            select="tokenize('annotation,prodnote,sidebar,address,covertitle,div,epigraph,imggroup,samp,caption,code,
            kbd,li,note,img,q,blockquote,level,level1,level2,level3,level4,level5,level6,td,th', ',')"/>


        <!-- select all imggroup descendants whose parents are not in the list of valid parent names -->
        <xsl:variable name="invalid-imggroups" 
            select="$elem/descendant::dtb:imggroup[empty(index-of($valid-parents, name(parent::node())))]"/>
        
        <!-- test if there is an imggroup whose parent is not in the set of valid parents -->
        <xsl:value-of select="empty($invalid-imggroups)"/>
        
    </xsl:function>

    
    <!-- match invalid imggroup parents that actually have an imggroup child -->
    <xsl:template
        match="*
      [
      not(empty(index-of($invalid-parents-A, name()))) 
      or 
      not(empty(index-of($invalid-parents-B, name())))
      ]
      [dtb:imggroup]">
        <xsl:message>Found unsuitable imggroup parent: {<xsl:value-of select="name()"/>},
                id={<xsl:value-of select="@id"/>}</xsl:message>
        <xsl:call-template name="process-invalid-imggroup-parent"/>
    </xsl:template>

    <!-- this template handles an element that has one or more imggroup child -->
    <xsl:template name="process-invalid-imggroup-parent">
        <xsl:choose>
            <xsl:when test="not(empty(index-of($invalid-parents-A, name())))">
                <xsl:call-template name="move-elem-out">
                    <xsl:with-param name="elem-name-to-move">imggroup</xsl:with-param>
                    <xsl:with-param name="split-into-elem" select="local-name()"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="not(empty(index-of($invalid-parents-B, name())))">
                <xsl:call-template name="move-elem-out">
                    <xsl:with-param name="elem-name-to-move">imggroup</xsl:with-param>
                    <xsl:with-param name="split-into-elem" select="'p'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="move-elem-out">
        <xsl:param name="elem-name-to-move"/>
        <xsl:param name="split-into-elem"/>

        
        <xsl:variable name="elem" select="."/>
        <xsl:variable name="first-child" select="child::node()[1]"/>

        <!-- move the element out a level -->
        <xsl:for-each-group select="*|text()[normalize-space()]"
            group-adjacent="local-name() = $elem-name-to-move">
            <xsl:choose>
                <!-- the imggroup itself-->
                <xsl:when test="current-grouping-key()">
                    <xsl:copy-of select="current-group()"/>
                </xsl:when>

                <xsl:otherwise>
                    <!-- split the parent element -->
                    <xsl:choose>
                        <!-- split into many of the same element -->
                        <xsl:when test="local-name($elem) = $split-into-elem">
                            <xsl:element name="{local-name($elem)}"
                                namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                
                                <xsl:apply-templates select="$elem/@*"/>
                                
                                <!-- for all except the first 'copy' of the original parent:
                                    don't copy the node's ID since then it will result in many nodes with the same ID -->
                                <xsl:if test="not(position() = 1 or local-name($first-child) = $elem-name-to-move)">
                                    <xsl:if test="$elem/@id">
                                        <!-- modifying the result of generate-id() by adding a character to the end
                                            seems to correct the problem of it not being unique; however, this 
                                            is an issue that should be explored in-depth -->
                                        <xsl:variable name="tmp" select="concat(generate-id(), 'z')"/>
                                        <xsl:message>Generating ID <xsl:value-of select="$tmp"/></xsl:message>
                                        <xsl:attribute name="id" select="$tmp"/>
                                    </xsl:if>
                                </xsl:if>
                                
                                <xsl:apply-templates select="current-group()"/>
                            
                            </xsl:element>
                        </xsl:when>
                        <!-- split into a different element type than the original -->
                        <xsl:otherwise>
                            <xsl:choose>
                                <!-- for the first group, use the original element name -->
                                <xsl:when
                                    test="position() = 1 or local-name($first-child) = $elem-name-to-move">
                                    <xsl:element name="{local-name($elem)}"
                                        namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                        <xsl:apply-templates select="$elem/@*"/>
                                        <xsl:apply-templates select="current-group()"/>
                                    </xsl:element>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:element name="{$split-into-elem}"
                                        namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                        
                                        <xsl:apply-templates select="$elem/@*"/>
                                        
                                        <!-- for all except the first 'copy' of the original parent:
                                        don't copy the node's ID since then it will result in many nodes with the same ID -->
                                        <xsl:if test="$elem/@id">
                                            <xsl:variable name="tmp" select="generate-id()"/>
                                            <xsl:message>Generating ID <xsl:value-of select="$tmp"/></xsl:message>
                                            <!-- modifying the result of generate-id() by adding a character to the end
                                                seems to correct the problem of it not being unique; however, this 
                                                is an issue that should be explored in-depth -->
                                            <xsl:attribute name="id" select="concat(generate-id(), 'z')"/>
                                        </xsl:if>
                                        
                                        <xsl:apply-templates select="current-group()"/>
                                        
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>

                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>
