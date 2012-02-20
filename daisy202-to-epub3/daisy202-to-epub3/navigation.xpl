<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xd="http://www.daisy.org/ns/pipeline/doc" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="pxi:daisy202-to-epub3-navigation" name="navigation" version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Make a EPUB3 Navigation Document based on the Content Documents.</xd:short>
    </p:documentation>

    <p:input port="ncc-navigation" primary="true">
        <p:documentation>
            <xd:short>An EPUB3 Navigation Document with contents based purely on the DAISY 2.02 NCC.</xd:short>
            <xd:example>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/navigation.xhtml"
                    original-base="file:/home/user/daisy202/ncc.html">...</html>
            </xd:example>
        </p:documentation>
    </p:input>
    <p:input port="content" primary="false" sequence="true">
        <p:documentation>
            <xd:short>The EPUB3 Content Documents.</xd:short>
            <xd:example>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Content/a.xhtml" original-base="file:/home/user/daisy202/a.html"
                    >...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/navigation.xhtml"
                    original-base="file:/home/user/daisy202/ncc.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Content/b.xhtml" original-base="file:/home/user/daisy202/b.html"
                    >...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Content/c.xhtml" original-base="file:/home/user/daisy202/c.html"
                    >...</html>
            </xd:example>
        </p:documentation>
    </p:input>
    <p:output port="navigation" primary="false">
        <p:documentation>
            <xd:short>The complete EPUB3 Navigation Document.</xd:short>
            <xd:example>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/navigation.xhtml"
                    original-base="file:/home/user/daisy202/ncc.html">...</html>
            </xd:example>
        </p:documentation>
        <p:pipe port="result" step="result-with-xml-base"/>
    </p:output>
    <p:output port="ncx" primary="false" sequence="true">
        <p:documentation>
            <xd:short>A NCX document generated based on the Navigation Document.</xd:short>
            <xd:example>
                <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">...</ncx>
            </xd:example>
        </p:documentation>
        <p:pipe port="ncx" step="store-ncx"/>
    </p:output>
    <p:output port="content-navfix" sequence="true">
        <p:documentation>
            <xd:short>The same sequence of EPUB3 Content Documents as arrived on the "content" port, but with the old Navigation Document replaced by the new
                one (if it's in the spine).</xd:short>
            <xd:example>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/a.xhtml"
                    original-base="file:/home/user/daisy202/a.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/navigation.xhtml"
                    original-base="file:/home/user/daisy202/ncc.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/b.xhtml"
                    original-base="file:/home/user/daisy202/b.html">...</html>
                <html xmlns="http://www.w3.org/1999/xhtml" xml:base="file:/home/user/epub3/epub/Publication/Content/c.xhtml"
                    original-base="file:/home/user/daisy202/c.html">...</html>
            </xd:example>
        </p:documentation>
        <p:pipe port="result" step="content"/>
    </p:output>
    <p:output port="fileset">
        <p:documentation>
            <xd:short>A fileset with references to the Navigation Document and the NCX.</xd:short>
            <xd:example>
                <d:fileset xmlns:d="http://www.daisy.org/ns/pipeline/data" xml:base="file:/home/user/epub3/epub/Publication/">
                    <d:file xml:base="navigation.xhtml" media-type="application/xhtml+xml"/>
                    <d:file xml:base="ncx.xml" media-type="application/x-dtbncx+xml"/>
                </d:fileset>
            </xd:example>
        </p:documentation>
        <p:pipe port="result" step="fileset"/>
    </p:output>
    <p:output port="store-complete" primary="false" sequence="true">
        <p:documentation>
            <xd:short>Results from storing the Navigation Document and the NCX.</xd:short>
            <xd:example>
                <c:result>file:/home/user/epub3/epub/Publication/navigation.xhtml</c:result>
                <c:result>file:/home/user/epub3/epub/Publication/ncx.xml</c:result>
            </xd:example>
        </p:documentation>
        <p:pipe port="result" step="store"/>
        <p:pipe port="result" step="store-ncx"/>
    </p:output>

    <p:option name="publication-dir" required="true">
        <p:documentation>
            <xd:short>URI to the EPUB3 Publication directory.</xd:short>
            <xd:example>file:/home/user/epub3/epub/Publication/</xd:example>
        </p:documentation>
    </p:option>
    <p:option name="content-dir" required="true">
        <p:documentation>
            <xd:short>URI to the EPUB3 Content directory.</xd:short>
            <xd:example>file:/home/user/epub3/epub/Publication/Content/</xd:example>
        </p:documentation>
    </p:option>
    <p:option name="compatibility-mode" required="true">
        <p:documentation>
            <xd:short>Whether or not to include NCX-file. Can be either 'true' (default) or 'false'.</xd:short>
        </p:documentation>
    </p:option>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl">
        <p:documentation>Calabash extension steps.</p:documentation>
    </p:import>
    <p:import href="resolve-links.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/xproc/fileset-library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/epub3-nav-utils/epub3-nav-library.xpl"/>

    <p:variable name="subdir" select="substring-after($content-dir,$publication-dir)"/>

    <p:documentation xd:target="parent">Make a Navigation Document based on the navs generated from the NCC and the outline generated from the
        content.</p:documentation>

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
                            <xsl:if test="$lang">
                                <xsl:attribute name="lang" select="$lang"/>
                                <xsl:attribute name="xml:lang" select="$lang"/>
                            </xsl:if>
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

            <p:for-each>
                <p:iteration-source>
                    <p:pipe port="content" step="navigation"/>
                </p:iteration-source>
                <p:variable name="xml-base" select="/*/@xml:base"/>
                <px:fileset-create>
                    <p:with-option name="base" select="$publication-dir"/>
                </px:fileset-create>
                <px:fileset-add-entry>
                    <p:with-option name="href" select="$xml-base"/>
                </px:fileset-add-entry>
            </p:for-each>
            <px:fileset-join name="store-ncx.spine"/>
            <p:sink/>

            <p:insert match="/*" position="first-child">
                <p:input port="source">
                    <p:pipe port="result" step="result-with-xml-base"/>
                </p:input>
                <p:input port="insertion">
                    <p:pipe port="result" step="store-ncx.spine"/>
                </p:input>
            </p:insert>
            <p:add-attribute match="/*" attribute-name="xml:base">
                <p:with-option name="attribute-value" select="concat($publication-dir,'navigation.xhtml')"/>
            </p:add-attribute>
            <p:xslt name="store-ncx.ncx-without-docauthors">
                <p:input port="parameters">
                    <p:empty/>
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
            <cx:message>
                <p:input port="source">
                    <p:inline>
                        <doc/>
                    </p:inline>
                </p:input>
                <p:with-option name="message" select="concat('stored ',$publication-dir,'ncx.xml')"/>
            </cx:message>
            <p:sink/>
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
                <cx:message>
                    <p:with-option name="message" select="'the navigation document is in the spine; replaced it with the updated version'"/>
                </cx:message>
            </p:when>
            <p:otherwise>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    <p:sink/>

</p:declare-step>
