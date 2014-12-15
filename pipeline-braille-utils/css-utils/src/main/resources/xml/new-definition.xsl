<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:new="css:new-definition"
                exclude-result-prefixes="#all"
                version="2.0">
    
    <xsl:include href="library.xsl"/>
    
    <xsl:variable name="properties-as-attributes" as="xs:boolean" select="true()"/>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:sequence select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:sequence select="."/>
    </xsl:template>
    
    <xsl:template match="css:box">
        <xsl:param name="parent-properties" as="element()*" select="()" tunnel="yes"/>
        <!--
            in: properties as specified
            out:
            - keep: properties that must be put on this box
            - drop: properties that don't have to be put on this box because they are the default
            - pending: properties that for some reason can't be put on this box but can't be ignored either
        -->
        <xsl:variable name="properties" as="element()*">
            <xsl:apply-templates select="css:specified-properties($new:properties, true(), true(), true(), .)"
                                 mode="property">
                <xsl:with-param name="context" select="." tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:copy>
            <xsl:sequence select="@* except (@style|@css:*[local-name()=$new:properties])"/>
            <xsl:choose>
                <xsl:when test="$properties-as-attributes">
                    <xsl:apply-templates select="$properties[self::keep]/*" mode="css:property-as-attribute"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="css:style-attribute(css:serialize-declaration-list($properties[self::keep]/*))"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates>
                <xsl:with-param name="parent-properties" tunnel="yes"
                                select="($properties[not(self::pending)]/*[not(@value='inherit')],
                                         for $p in $properties[not(self::pending)]/*[@value='inherit']/@name
                                           return $parent-properties[@name=$p])"/>
                <xsl:with-param name="pending-properties" tunnel="yes"
                                select="($properties[self::pending]/*[not(@value='inherit')],
                                         for $p in $properties[self::pending]/*[@value='inherit']/@name
                                           return $parent-properties[@name=$p])"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <!--
        concretize inherit on top-level boxes only
    -->
    <xsl:template match="css:property" mode="css:inherit">
        <xsl:param name="context" as="element()"/>
        <xsl:sequence select="if (@value='inherit' and not($context/ancestor::css:box))
                              then css:property(@name, 'initial') else ."/>
    </xsl:template>
    
    <!--
        concretize inherit when there is a pending property
    -->
    <xsl:template match="css:property[@value='inherit']" mode="property" priority="1">
        <xsl:param name="pending-properties" as="element()*" select="()" tunnel="yes"/>
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:choose>
            <xsl:when test="$pending-properties[@name=$name]">
                <xsl:apply-templates select="$pending-properties[@name=$name]" mode="#current"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        drop inherit if the property is inherited by default according to the new definition
    -->
    <xsl:template match="css:property[@value='inherit']" mode="property" priority="0.9">
        <xsl:param name="context" as="element()" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="new:is-inherited(@name, $context)">
                <drop>
                    <xsl:sequence select="."/>
                </drop>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        concretize inherit when it is not valid according to the new definition
    -->
    <xsl:template match="css:property[@value='inherit']" mode="property" priority="0.8">
        <xsl:param name="context" as="element()" tunnel="yes"/>
        <xsl:param name="parent-properties" as="element()*" select="()" tunnel="yes"/>
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:choose>
            <xsl:when test="new:is-valid(., $context)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$parent-properties[@name=$name]" mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        drop a property if it is not inherited and has the initial value according to the new
        definition
    -->
    <xsl:template match="css:property[not(@value='inherit')]" mode="property" priority="0.7">
        <xsl:param name="context" as="element()" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="not($context/ancestor::css:box and new:is-inherited(@name, $context))
                            and @value=new:initial-value(@name, $context)">
                <drop>
                    <xsl:sequence select="."/>
                </drop>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        make a property pending when it is not valid according to the new definition
    -->
    <xsl:template match="css:property[not(@value='inherit')]" mode="property" priority="0.6">
        <xsl:param name="context" as="element()" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="new:is-valid(., $context)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <pending>
                    <xsl:sequence select="."/>
                </pending>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--
        drop a property if it doesn't apply according to the old defintion but does according to the
        new definition
    -->
    <xsl:template match="css:property" mode="property" priority="0.5">
        <xsl:param name="context" as="element()" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="css:applies-to(@name, ($context/@type,'inline')[1])
                            or not(new:applies-to(@name, $context))">
                <keep>
                    <xsl:sequence select="."/>
                </keep>
            </xsl:when>
            <xsl:otherwise>
                <drop>
                    <xsl:sequence select="."/>
                </drop>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
