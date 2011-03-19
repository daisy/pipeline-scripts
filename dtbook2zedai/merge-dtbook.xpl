<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step version="1.0" name="merge-dtbook" type="d2z:merge-dtbook"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:cxo="http://xmlcalabash.com/ns/extensions/osutils"
    xmlns:dtb="http://www.daisy.org/z3986/2005/dtbook/"
    xmlns:d2z="http://pipeline.daisy.org/ns/dtbook2zedai/" xmlns:dc="http://purl.org/dc/terms/"
    exclude-inline-prefixes="cx">
    <!-- 
        
        This XProc script is part of the DTBook2ZedAI module.
        The module's homepage is here: http://code.google.com/p/daisy-pipeline/wiki/DTBook2ZedAI
        
        TODO: 
         * copy referenced resources (such as images)
         * deal with xml:lang (either copy once and put in dtbook/@xml:lang or, if different languages are used, copy the @xml:lang attr into the respective sections.
    -->

    <p:input port="source" primary="true" sequence="true"/>
    <p:input port="parameters" kind="parameter"/>
    <p:output port="result" primary="true">
        <p:pipe port="result" step="validate-zedai"/>
    </p:output>
    
    <p:option name="output" select="''"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    
    <p:for-each name="validate-input">
        <p:output port="result">
            <p:pipe step="ident" port="result"/>
        </p:output>

        <p:iteration-source select="/"/>

        <p:validate-with-relax-ng>
            <p:input port="schema">
                <p:document href="./schema/dtbook-2005-3.rng"/>
            </p:input>
        </p:validate-with-relax-ng>

        <p:identity name="ident"/>

    </p:for-each>

    <p:for-each name="for-each-head">
        <p:iteration-source select="//dtb:dtbook/dtb:head/*">
            <p:pipe port="result" step="validate-input"/>
        </p:iteration-source>
        <p:output port="result"/>

        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-head" wrapper="head"
        wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        <p:input port="source">
            <p:pipe step="for-each-head" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:for-each name="for-each-frontmatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:frontmatter/*">
            <p:pipe port="result" step="validate-input"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-frontmatter" wrapper="frontmatter"
        wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        <p:input port="source">
            <p:pipe step="for-each-frontmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:for-each name="for-each-bodymatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:bodymatter/*">
            <p:pipe port="result" step="validate-input"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-bodymatter" wrapper="bodymatter"
        wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        <p:input port="source">
            <p:pipe step="for-each-bodymatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:for-each name="for-each-rearmatter">
        <p:output port="result"/>
        <p:iteration-source select="//dtb:dtbook/dtb:book/dtb:rearmatter/*">
            <p:pipe port="result" step="validate-input"/>
        </p:iteration-source>
        <p:identity/>
    </p:for-each>

    <p:wrap-sequence name="wrap-rearmatter" wrapper="rearmatter"
        wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        <p:input port="source">
            <p:pipe step="for-each-rearmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:wrap-sequence wrapper="dtbook" wrapper-namespace="http://www.daisy.org/z3986/2005/dtbook/">
        
        <p:input port="source">
            <p:pipe step="wrap-head" port="result"/>
            <p:pipe step="wrap-frontmatter" port="result"/>
            <p:pipe step="wrap-bodymatter" port="result"/>
            <p:pipe step="wrap-rearmatter" port="result"/>
        </p:input>
    </p:wrap-sequence>

    <p:add-attribute match="/dtb:dtbook" attribute-name="version" attribute-value="2005-3"/>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

                    <xsl:output method="xml" indent="yes"/>

                    <xsl:template match="/">
                        <xsl:apply-templates/>
                    </xsl:template>

                    <!-- sort metadata -->
                    <xsl:template match="dtb:head">

                        <!-- save an identifier -->
                        <xsl:variable name="identifier"
                            select="dtb:meta[@name='dc:Identifier'][1]/@content"/>

                        <xsl:variable name="unique-list"
                            select="dtb:meta[not(@name=following::dtb:meta/@name)][not(@content=following::dtb:meta/@content)]"/>


                        <!-- copy all non-duplicate metadata except identifiers -->
                        <xsl:for-each select="$unique-list">

                            <xsl:if test="not(@name = 'dc:Identifier') and not(@name = 'dtb:uid')">
                                <xsl:copy-of select="."/>
                            </xsl:if>

                        </xsl:for-each>

                        <!-- create our own identifier to represent the merged version of the book. -->
                        <!-- TODO: this should be a user-customizable option -->
                        <xsl:element name="meta" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                            <xsl:attribute name="dc:Identifier">
                                <xsl:value-of select="concat($identifier, 'merged-book')"/>
                            </xsl:attribute>
                        </xsl:element>

                    </xsl:template>

                    <xsl:template match="dtb:book/dtb:frontmatter">
                        <xsl:apply-templates/>
                    </xsl:template>

                    <!-- multiple docauthors allowed, just filter the duplicates -->
                    <xsl:template match="dtb:docauthor">

                        <xsl:if test="not(. = preceding-sibling::*)">
                            <xsl:copy-of select="."/>
                        </xsl:if>

                    </xsl:template>

                    <!-- copy the first occurrence and wrap the rest in <p> if they are different -->
                    <xsl:template match="dtb:doctitle">
                        
                        <!-- if this is not a duplicate title -->
                        <xsl:if test="not(. = preceding-sibling::*)">
                            <xsl:choose>
                                <!-- when it's the first doctitle element -->
                                <xsl:when test="not(name() = preceding-sibling::*/name())">
                                    <xsl:copy-of select="."/>
                                </xsl:when>
                                <!-- subsequent non-duplicate doctitle elements are wrapped in p -->
                                <xsl:otherwise>
                                    <xsl:element name="p" namespace="http://www.daisy.org/z3986/2005/dtbook/">
                                        <xsl:apply-templates/>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>

                    </xsl:template>

                    <!-- identity template that strips out empty nodes -->
                    <xsl:template match="@*|node()">
                        <xsl:if test=". != '' or ./@* != ''">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:if>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>

    <p:validate-with-relax-ng name="validate-zedai">
        <p:input port="schema">
            <p:document href="./schema/dtbook-2005-3.rng"/>
        </p:input>
    </p:validate-with-relax-ng>
    
</p:declare-step>
