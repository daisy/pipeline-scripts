<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc" type="pxi:daisy202-to-epub3-navigation" name="navigation" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Transform the DAISY 2.02 NCC into a EPUB 3 Navigation Document.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="ncc">The NCC as wellformed XHTML.</xd:input>
        <xd:input port="id-mapping">The mapping of id-attributes and fragment identifiers of the resulting documents to the original documents.</xd:input>
        <xd:output port="store-complete">Pipe connection for 'p:store'-dependencies.</xd:output>
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be stored.</xd:option>
    </p:documentation>

    <p:input port="ncc-navigation" primary="true"/>
    <p:input port="content" primary="false" sequence="true"/>
    <p:output port="navigation" primary="false">
        <p:pipe port="result" step="result-with-xml-base"/>
    </p:output>
    <p:output port="ncx" primary="false" sequence="true">
        <p:pipe port="ncx" step="store-ncx"/>
    </p:output>
    <p:output port="content-navfix" sequence="true">
        <p:pipe port="result" step="content"/>
    </p:output>
    <p:output port="fileset">
        <p:pipe port="result" step="fileset"/>
    </p:output>
    <p:output port="store-complete" primary="false" sequence="true">
        <p:pipe port="result" step="store"/>
        <p:pipe port="result" step="store-ncx"/>
    </p:output>

    <p:output port="dbg" sequence="true">
        <p:pipe port="result" step="ncc-nav-toc"/>
    </p:output>

    <p:option name="publication-dir" required="true"/>
    <p:option name="content-dir" required="true"/>
    <p:option name="pub-id" required="true"/>
    <p:option name="compatibility-mode" required="true"/>

    <p:import href="resolve-links.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-nav-utils/epub3-nav-library.xpl"/>

    <p:variable name="subdir" select="substring-after($content-dir,$publication-dir)"/>

    <p:documentation xd:target="parent">Make a Navigation Document based on the navs generated from the NCC and the outline generated from the content.</p:documentation>

    <px:epub3-nav-create-toc name="content-nav-toc">
        <p:input port="source">
            <p:pipe port="content" step="navigation"/>
        </p:input>
    </px:epub3-nav-create-toc>
    <p:sink/>

    <!-- TODO: create nav with html-lot-annotator.xsl here when it's done -->
    <!-- TODO: create nav with html-loi-annotator.xsl here when it's done -->

    <p:identity name="ncc-nav-toc">
        <p:input port="source" select="//html:nav[@*[name()='epub:type']='toc']">
            <p:pipe port="ncc-navigation" step="navigation"/>
        </p:input>
    </p:identity>
    <p:sink/>
    <p:identity name="ncc-nav-page-list">
        <p:input port="source" select="//html:nav[@*[name()='epub:type']='page-list']">
            <p:pipe port="ncc-navigation" step="navigation"/>
        </p:input>
    </p:identity>
    <p:sink/>
    <p:identity name="ncc-nav-landmarks">
        <p:input port="source" select="//html:nav[@*[name()='epub:type']='landmarks']">
            <p:pipe port="ncc-navigation" step="navigation"/>
        </p:input>
    </p:identity>
    <p:sink/>

    <!--<px:epub3-nav-annotate-hidden name="toc">
        <p:input port="source">
            <p:pipe port="result" step="content-nav-toc"/>
        </p:input>
        <p:input port="visible">
            <p:pipe port="result" step="ncc-toc"/>
        </p:input>
    </px:epub3-nav-annotate-hidden>-->
    <p:identity name="toc">
        <!-- TODO: replace with px:epub3-nav-annotate-hidden when that step has been implemented -->
        <p:input port="source">
            <p:pipe port="result" step="ncc-nav-toc"/>
        </p:input>
    </p:identity>
    <p:sink/>

    <px:epub3-nav-aggregate>
        <p:input port="source">
            <p:pipe step="toc" port="result"/>
            <p:pipe step="ncc-nav-page-list" port="result"/>
            <p:pipe step="ncc-nav-landmarks" port="result"/>
        </p:input>
    </px:epub3-nav-aggregate>
    <p:xslt>
        <!-- TODO: This XSLT is here temporarily until px:epub3-nav-aggregate supports title and language customization -->
        <p:with-param name="title" select="//html:title">
            <p:pipe port="ncc-navigation" step="navigation"/>
        </p:with-param>
        <p:with-param name="lang" select="(//@html:lang | //@xml:lang)[1]">
            <p:pipe port="ncc-navigation" step="navigation"/>
        </p:with-param>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:output indent="yes"/>
                    <xsl:param name="title" required="yes"/>
                    <xsl:param name="lang" select="''"/>
                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="lang" select="$lang"/>
                            <xsl:attribute name="xml:lang" select="$lang"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="html:title">
                        <xsl:copy>
                            <xsl:value-of select="$title"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt>
    <p:identity name="result-without-xml-base"/>

    <p:store name="store" indent="true">
        <p:with-option name="href" select="concat($publication-dir,'navigation.xhtml')"/>
    </p:store>

    <p:add-attribute match="/*" attribute-name="xml:base">
        <p:with-option name="attribute-value" select=".">
            <p:pipe port="result" step="store"/>
        </p:with-option>
        <p:input port="source">
            <p:pipe port="result" step="result-without-xml-base"/>
        </p:input>
    </p:add-attribute>
    <p:identity name="result-with-xml-base"/>
    <p:sink/>

    <p:choose name="store-ncx">
        <p:when test="$compatibility-mode='true'">
            <p:output port="ncx" sequence="true">
                <p:pipe port="result" step="store-ncx.ncx-with-base"/>
            </p:output>
            <p:output port="result" sequence="true">
                <p:pipe port="result" step="store-ncx.store"/>
            </p:output>
            <p:xslt name="store-ncx.ncx-without-docauthors">
                <p:input port="parameters">
                    <p:empty/>
                </p:input>
                <p:input port="source">
                    <p:pipe port="result" step="result-with-xml-base"/>
                </p:input>
                <p:input port="stylesheet">
                    <p:document href="http://www.daisy.org/pipeline/modules/epub3-nav-utils/nav-to-ncx.xsl"/>
                </p:input>
            </p:xslt>
            <p:for-each>
                <p:iteration-source select="//html:meta[@name='dc:creator']">
                    <p:pipe port="ncc-navigation" step="navigation"/>
                </p:iteration-source>
                <p:template>
                    <p:input port="template">
                        <p:inline xmlns="http://www.daisy.org/z3986/2005/ncx/" exclude-inline-prefixes="#all">
                            <docAuthor>
                                <text>{string(/*/@content)}</text>
                            </docAuthor>
                        </p:inline>
                    </p:input>
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                </p:template>
            </p:for-each>
            <p:identity name="store-ncx.docauthors"/>
            <p:insert xmlns="http://www.daisy.org/z3986/2005/ncx/" match="/*/*[2]" position="after" name="store-ncx.ncx">
                <p:input port="source">
                    <p:pipe port="result" step="store-ncx.ncx-without-docauthors"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe port="result" step="store-ncx.docauthors"/>
                </p:input>
            </p:insert>
            <p:store name="store-ncx.store" indent="true">
                <p:with-option name="href" select="concat($publication-dir,'ncx.xml')"/>
            </p:store>
            <p:add-attribute name="store-ncx.ncx-with-base" attribute-name="xml:base" match="/*">
                <p:input port="source">
                    <p:pipe port="result" step="store-ncx.ncx"/>
                </p:input>
                <p:with-option name="attribute-value" select="/*">
                    <p:pipe port="result" step="store-ncx.store"/>
                </p:with-option>
            </p:add-attribute>
        </p:when>
        <p:otherwise>
            <p:output port="ncx" sequence="true">
                <p:empty/>
            </p:output>
            <p:output port="result" sequence="true">
                <p:empty/>
            </p:output>
            <p:sink>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:sink>
        </p:otherwise>
    </p:choose>

    <px:fileset-create>
        <p:with-option name="base" select="$publication-dir"/>
    </px:fileset-create>
    <p:choose>
        <p:when test="$compatibility-mode='true'">
            <px:fileset-add-entry>
                <p:with-option name="href" select="/*/@xml:base">
                    <p:pipe port="ncx" step="store-ncx"/>
                </p:with-option>
                <p:with-option name="media-type" select="'application/x-dtbncx+xml'"/>
            </px:fileset-add-entry>
        </p:when>
        <p:otherwise>
            <p:identity/>
        </p:otherwise>
    </p:choose>
    <px:fileset-add-entry>
        <p:with-option name="href" select="/*/@xml:base">
            <p:pipe port="result" step="result-with-xml-base"/>
        </p:with-option>
        <p:with-option name="media-type" select="'application/xhtml+xml'"/>
    </px:fileset-add-entry>
    <p:identity name="fileset"/>
    <p:sink/>

    <p:for-each name="content">
        <p:output port="result" sequence="true"/>
        <p:iteration-source>
            <p:pipe port="content" step="navigation"/>
        </p:iteration-source>
        <p:variable name="nav-base" select="/*/@xml:base">
            <p:pipe port="result" step="result-with-xml-base"/>
        </p:variable>
        <p:choose>
            <p:when test="/*/@xml:base=$nav-base">
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="result" step="result-with-xml-base"/>
                    </p:input>
                </p:identity>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:sink/>

</p:declare-step>
