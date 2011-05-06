<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    exclude-result-prefixes="dtb f" version="2.0"
    xmlns:f="http://www.daisy.org/ns/pipeline/internal-function">
    
    <!--
        Move target element out and split the element(s) that used to contain it.
        Input:
            root-elem: The document root
            valid-parents-list: elements that are allowed to be parents for the target element (a tokenized list of local name values)
            target-elem-name: the element that will be moved (local name value)
        
    -->
    
    <xsl:import href="moveout-template.xsl"/>
    
    <xsl:output indent="yes" method="xml"/>
    
    <!-- recursive -->
    <xsl:template name="test-and-move">
        
        <xsl:param name="target-elem-name" tunnel="yes"/>
        <xsl:param name="valid-parents-list" tunnel="yes"/>
        <xsl:param name="root-elem"/>
        
        <xsl:message>moveout-generic.xsl</xsl:message>
        
        <xsl:choose>
            
            <xsl:when test="f:test-valid($root-elem, $target-elem-name, $valid-parents-list) = true()">
                <xsl:message>Document is valid with regards to the given target element.</xsl:message>
                <xsl:copy-of select="$root-elem"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Document is invalid.  An element must be moved out of its current parent.</xsl:message>
                <xsl:variable name="result">
                    <xsl:apply-templates select="$root-elem"/>
                </xsl:variable>
                
                <!-- the recursive call -->
                <xsl:call-template name="test-and-move">
                    <xsl:with-param name="root-elem" select="if ($result instance of document-node()) then $result/*[1] else $result"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="f:test-valid">
        <!-- TODO: is this the correct type? -->
        <xsl:param name="root-elem" as="element()"/>
        <xsl:param name="target-elem-name"/>
        <xsl:param name="valid-parents-list"/>
        
        <xsl:message>moveout-generic.xsl: Testing validity...</xsl:message>
        
        <!-- select all target element descendants whose parents are not in the list of valid parent names -->
        <xsl:variable name="invalid-target-elems"
            select="$root-elem/descendant::*[local-name() = $target-elem-name][not(local-name(parent::node()) = $valid-parents-list)]"/>
        
        
        <!-- test if there is a target element whose parent is not in the set of valid parents -->
        <xsl:value-of select="empty($invalid-target-elems)"/>
    </xsl:function>
    
    
    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <!-- match invalid element parents that actually have an invalid element child -->
    <xsl:template match="node()">
        <xsl:param name="valid-parents-list" tunnel="yes"/>
        <xsl:param name="target-elem-name" tunnel="yes"/>
        
        <xsl:choose>
            <xsl:when
                test="not(local-name() = $valid-parents-list) and (child::*/local-name() = $target-elem-name)">
                <xsl:message>Found unsuitable parent: name = <xsl:value-of select="local-name()"/> id = <xsl:value-of select="@id"/></xsl:message>
                <xsl:call-template name="process-invalid-target-elem-parent"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- identity template -->
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- this template handles an element that has one or more target element child -->
    <xsl:template name="process-invalid-target-elem-parent">
        <xsl:param name="valid-parents-list" tunnel="yes"/>
        <xsl:param name="target-elem-name" tunnel="yes"/>
        
        <xsl:variable name="cannot-split" select="tokenize('h1,h2,h3,h4,h5,h6,hd', ',')"/>
        
        <xsl:choose>
            <xsl:when test="not(local-name() = $valid-parents-list)">
                <xsl:choose>
                    <!-- when this is an element that cannot be split into duplicates of itself -->
                    <xsl:when test="local-name() = $cannot-split">
                        <xsl:call-template name="move-elem-out">
                            <xsl:with-param name="elem-to-move-name" select="$target-elem-name"/>
                            <xsl:with-param name="split-into-elem-name" select="'p'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="move-elem-out">
                            <xsl:with-param name="elem-to-move-name" select="$target-elem-name"/>
                            <xsl:with-param name="split-into-elem-name" select="local-name()"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
