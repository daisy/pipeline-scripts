<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns="http://www.loc.gov/mods/v3" 
    exclude-result-prefixes="xd" version="2.0">

    <xsl:output indent="yes" method="xml"/>

    <!-- create MODS output from metadata in a DTBook document-->
    
    <!-- TODO
        
        * process more than one dtb:producer 
        * match the following:
            - dc:Date (how different from originInfo & dtb:producedDate)
            - dc:Publisher (how different from originInfo & dtb:producer)
            - dc:Format
            - dc:Source when @scheme is not 'isbn'
            - dc:Relation
            - dc:Coverage (DAISY 2005 standard notes 'not expected in DTBs')
            - dc:
    -->
    
    <mods xmlns="http://www.loc.gov/mods/v3" version="3.3">
        
        <xsl:template match="//head">
            
            <xsl:apply-templates/>
            
            <!-- if there are any dtb:source* metadata properties, then create the relatedItem element -->
            <xsl:if test="./dtb:meta[contains(@name, 'dtb:source')]">
                <relatedItem type="original">

                    <xsl:if test="./dtb:meta[@name = 'dtb:sourceRights']">
                        <accessCondition><xsl:value-of select="@content"/></accessCondition>
                    </xsl:if>

                    <xsl:if test="./dtb:meta[@name = 'dtb:sourceTitle']">
                        <titleInfo>
                            <title><xsl:value-of select="@content"/></title>
                        </titleInfo>
                    </xsl:if>

                    <!-- if any of these properties are available, then create and populate the originInfo element -->
                    <xsl:if
                        test="./dtb:meta[@name = 'dtb:sourceDate'] or ./dtb:meta[@name = 'dtb:sourceEdition'] or 
                           ./dtb:meta[@name = 'dtb:sourcePublisher']">
                        <originInfo>

                            <xsl:if test="./dtb:meta[@name = 'dtb:sourceDate']">
                                <dateIssued><xsl:value-of select="@content"/></dateIssued>
                            </xsl:if>
                            <xsl:if test="./dtb:meta[@name = 'dtb:sourceEdition']">
                                <edition><xsl:value-of select="@content"/></edition>
                            </xsl:if>
                            <xsl:if test="./dtb:meta[@name = 'dtb:sourcePublisher']">
                                <publisher><xsl:value-of select="@content"/></publisher>
                            </xsl:if>
                            
                        </originInfo>
                    </xsl:if>

                </relatedItem>
            </xsl:if>

            <!-- if there are any dtb:produce* metadata properties, then create the originInfo element -->
            <xsl:if test="./dtb:meta[contains(@name, 'dtb:producer')] or ./dtb:meta[contains(@name, 'dtb:producedDate')]">
                <originInfo>
                    <xsl:if test="./dtb:meta[contains(@name, 'dtb:producer')]">
                        <publisher><xsl:value-of select="@content"/></publisher>
                    </xsl:if>
                    <xsl:if test="./dtb:meta[contains(@name, 'dtb:producedDate')]">
                        <dateCreated><xsl:value-of select="@content"/></dateCreated>
                    </xsl:if>
                </originInfo>
            </xsl:if>
        </xsl:template>
        
        <!-- process dublin core metadata -->
        <xsl:template match="dtb:meta[@name = 'dc:Title']">
            <titleInfo>
                <title><xsl:value-of select="@content"/></title>
            </titleInfo>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name= 'dc:Creator']">
            <name>
                <namePart><xsl:value-of select="@content"/></namePart>
                <role>
                    <roleTerm type="text">author</roleTerm>
                </role>
            </name>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name= 'dc:Identifier']">
            <identifier type="uid"><xsl:value-of select="@content"/></identifier>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name = 'dc:Language']">
            <language>
                <languageTerm type="code" authority="rfc3066"><xsl:value-of select="@content"/></languageTerm>
            </language>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name = 'dc:Subject']">
            <subject>
                <topic><xsl:value-of select="@content"/></topic>
            </subject>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name = 'dc:Description']">
            <note><xsl:value-of select="@content"/></note>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name = 'dc:Type']">
            <typeOfResource><xsl:value-of select="@content"/></typeOfResource>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name = 'dc:Source' and @scheme = 'isbn']">
            <identifier type="isbn"><xsl:value-of select="@content"/></identifier>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name= 'dc:Contributor']">
            <name>
                <namePart><xsl:value-of select="@content"/></namePart>
                <role>
                    <roleTerm type="text">contributor</roleTerm>
                </role>
            </name>
        </xsl:template>
        
        <xsl:template match="dtb:meta[@name= 'dc:Rights']">
            <accessCondition><xsl:value-of select="@content"/></accessCondition>
        </xsl:template>
        
    </mods>


</xsl:stylesheet>
