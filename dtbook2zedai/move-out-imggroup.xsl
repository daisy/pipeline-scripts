<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xd dtb" version="2.0">

    <xd:doc>
        <xd:desc>Move imggroup out a level and split the element that used to contain it.</xd:desc>
    </xd:doc>

    <xsl:output indent="yes" method="xml"/>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!-- these are all the elements that need imggroup moved before they can be turned into ZedAI elements -->
    <xsl:template match="dtb:a | dtb:abbr | dtb:acronym | dtb:author | dtb:bdo | dtb:bridgehead | dtb:byline | 
        dtb:cite | dtb:dateline | dtb:dd | dtb:dfn | dtb:docauthor | dtb:doctitle | dtb:em | dtb:h1 | dtb:h2 |
        dtb:h3 | dtb:h4 | dtb:h5 | dtb:h6 | dtb:hd | dtb:line | dtb:linegroup | dtb:p | dtb:q | dtb:sent |
        dtb:span | dtb:strong | dtb:sub | dtb:sup | dtb:title | dtb:w">
        <xsl:call-template name="move-elem-out">
            <xsl:with-param name="elem-name">imggroup</xsl:with-param>
            <!-- TODO: not all elements will split into many versions of themselves.  some can only exist
                once, such as h1-6 .  therefore, there is a parameter to use to specify an alternative.
                for example, h1 could specify p to transform <h1><code..><imggroup.../><code../></h1> into
                <h1><code../></h1><imggroup.../><p><code.../></p>.
            -->
            <xsl:with-param name="split-into-elem"><xsl:value-of select="name()"></xsl:value-of></xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- find the nearest parent that can contain imggroup -->
    
    <!-- 
    in zedai, imggroup becomes block.  the allowed parents of block that appear in this dtbook-based conversion are:
    annotation, aside, block, caption, code, description, item, note, object, quote, section, td, th 

    in dtbook, the elements that get turned into those elements are:
        zedai:annotation = annotation, prodnote
        zedai:aside = sidebar 
        zedai:block = div, address, epigraph, covertitle, samp, imggroup
        zedai:caption = caption
        zedai:code = code, kbd
        zedai:description = n/a
        zedai:item = li
        zedai:note = note
        zedai:object = img
        zedai:quote = blockquote, q
        zedai:section = level1, level2, level3, level4, level5, level6, level
        zedai:td = td
        zedai:th = th

        so, when moving imggroup, we have to search up the parent chain until one of these 
        dtbook elements is encountered, and make imggroup a child of that element.


        Not entirely sure how to do this in xslt.
        e.g.
        Start with this:
        <level1>
            <p>
                <a href="abcd.com">
                    <span>This link</span>
                    <imggroup ../>
                    will help
                </a>
            </p>
        </level1>
        
        and transform to this:
        
        <level1>
            <p>
                <a href="abcd.com">
                    <span>This link</span>
                </a>
            </p>
            <imggroup../>
            <p>
                <a href="abcd.com">
                    will help
                </a>
            </p>
       </level1>
       
       
       we could repeat this transformation until the file is sorted to our satisfaction, but that seems like overkill
       
       there could be other desireable results too, such as moving imggroup before or after (and outside) its former parent:
       
       <level1>
            <p>
                <a href="abcd.com">
                    <span>This link</span> will help
                </a>
            </p>
            <imggroup.../>
       </level1>
        
    -->    
    <xsl:template name="move-elem-out">
        <xsl:param name="elem-name"/>
        <xsl:param name="split-into-elem"/>
        
        <!-- the element to split out: boolean(self::dtb:$elem-name) -->
        <!-- want to use this param in group-adjacent -->
        <xsl:param name="group-name">
            <xsl:value-of select="concat(concat('boolean(', concat('self::dtb:', $elem-name)), ')')" />
        </xsl:param>
        
        <!-- save the parent element -->
        <xsl:variable name="elem" select="."/>

        <xsl:choose>
            <xsl:when test="./dtb:imggroup">                
                <!-- move imggroup -->
                <xsl:for-each-group select="*|text()[normalize-space()]"
                    group-adjacent="self::dtb:imggroup">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <xsl:element name="imggroup"
                                namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:apply-templates select="@*"/>
                                <xsl:apply-templates/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- split the parent element -->
                            <xsl:element name="{name($elem)}"
                                namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                <xsl:apply-templates select="$elem/@*"/>
                                <xsl:apply-templates select="current-group()"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
