<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils" xmlns:mo="http://www.w3.org/ns/SMIL"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:pxp="http://exproc.org/proposed/steps"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:opf="http://www.idpf.org/2007/opf"
    xmlns:xd="http://www.daisy.org/ns/pipeline/doc" type="px:navigation" name="navigation"
    version="1.0">

    <p:documentation xd:target="parent">
        <xd:short>Transform the DAISY 2.02 NCC into a EPUB 3 Navigation Document.</xd:short>
        <xd:author>
            <xd:name>Jostein Austvik Jacobsen</xd:name>
            <xd:mailto>josteinaj@gmail.com</xd:mailto>
            <xd:organization>NLB</xd:organization>
        </xd:author>
        <xd:maintainer>Jostein Austvik Jacobsen</xd:maintainer>
        <xd:input port="ncc">The NCC as wellformed XHTML.</xd:input>
        <xd:input port="id-mapping">The mapping of id-attributes and fragment identifiers of the
            resulting documents to the original documents.</xd:input>
        <xd:output port="store-complete">Pipe connection for 'p:store'-dependencies.</xd:output>
        <xd:option name="content-dir">URI to the directory where all the EPUB 3 content should be
            stored.</xd:option>
        <xd:import href="../utilities/file-utils/fileset-library.xpl">For manipulating
            filesets.</xd:import>
    </p:documentation>

    <p:input port="ncc" primary="true"/>
    <p:input port="mediaoverlay" primary="false"/>
    <p:output port="store-complete">
        <p:pipe port="result" step="store"/>
    </p:output>

    <p:option name="content-dir" required="true"/>

    <!--p:documentation>
        <xd:short>Resolve SMIL-hrefs to XHTML-hrefs.</xd:short>
        <xd:detail>
            <p>In DAISY 2.02, the NCC and text content documents refers to SMIL-files in their &lt;a
                href="smil-file.smil#smil-fragment"/&gt;-links, and those SMIL-files in turn refer
                to a text content document in their &lt;a
                href="text-file.xhtml#text-fragment"/&gt;-links. This is redundant information, so
                in EPUB 3, the Media Overlays refers to Content Documents (including the Navigation
                Document), but not the other way around. In EPUB3 there is at most one Media
                Overlay for each Content Document and exactly one Content Document for each Media
                Overlay. The Media Overlay corresponding to a certain text element can be determined
                by looking it up in the Package Document in EPUB3.</p>
            <p>This means that to transform a DAISY 2.02 text content document (including the NCC)
                into an EPUB 3 Content Document, we'll have to strip away all the unnecessary links.
                So we identify all the links that refers to themselves indirectly through a
                SMIL-file, and remove those links. However, the remaining links are kept, which can
                point to either another text element in the book, or an external URI.</p>
        </xd:detail>
    </p:documentation>
    <p:viewport match="//html:a">
        <p:variable name="smil-href" select="tokenize(/*/@href,'#')[1]"/>
        <p:variable name="smil-id"
            select="if (contains(/*/@href,'#')) then tokenize(/*/@href,'#')[last()] else ''"/>
        <p:add-attribute match="/*" attribute-name="href">
            <p:with-option name="attribute-value"
                select="concat(
                //c:entry[@smil-href=$smil-href]/@content-href,
                if ($smil-id)
                   then concat('#', //c:entry[@smil-href=$smil-href[1]]/c:id[@smil-id=$smil-id]/@content-id)
                   else ''
                )">
                <p:pipe port="id-mapping" step="navigation"/>
            </p:with-option>
        </p:add-attribute>
    </p:viewport-->

    <p:documentation>Transform the NCC into a Navigation Document.</p:documentation>
    <p:xslt name="navigation.xhtml">
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:document href="ncc2navigation.xsl"/>
        </p:input>
    </p:xslt>
    <p:delete match="html:ol[not(*)]"/>

    <!--p:documentation>For each media overlay</p:documentation>
    <p:for-each name="navigation.iterate-mediaoverlay">
        <p:iteration-source>
            <p:pipe port="mediaoverlay" step="navigation"/>
        </p:iteration-source>
        <p:variable name="mo-base" select="/*/@xml:base"/>
        <p:identity name="navigation.iterate-mediaoverlay.mediaoverlay"/>

        <p:documentation>For each link in the navigation document that references the current media
            overlay</p:documentation>
        <p:for-each>
            <p:iteration-source select="//html:a[p:resolve-uri(tokenize(@href,'#')[1])=$mo-base]">
                <p:pipe port="result" step="navigation.xhtml"/>
            </p:iteration-source>
            <p:variable name="fragment"
                select="if (contains(/*/@href,'#')) then tokenize(/*/@href,'#')[last()] else ''"/>

            <p:documentation>"For each" (there will only be one) text element in the media overlay
                that is references from the navigation document</p:documentation>
            <p:for-each>
                <p:iteration-source
                    select="//mo:text[@id=$fragment or parent::mo:par/@id=$fragment]">
                    <p:pipe port="result" step="navigation.iterate-mediaoverlay.mediaoverlay"/>
                </p:iteration-source>

                <p:documentation>Replace the @href in the navigation document with the one found in
                    the smil (also fixing the file extension)</p:documentation>
                <p:add-attribute match="/*" attribute-name="href">
                    <p:with-option name="attribute-value"
                        select="replace(@href,'^(.*)\.[^\.]*(#.*)$','$1.xhtml$2')"/>
                </p:add-attribute>
            </p:for-each>
        </p:for-each>
    </p:for-each-->

    <!--p:xslt>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
                    <xsl:template match="@*|node()">
                        <xsl:copy>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                    <xsl:template match="html:a">
                        <xsl:copy>
                            <xsl:apply-templates select="@*"/>
                            <xsl:attribute name="href" select="@href"/>
                            <xsl:apply-templates select="node()"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
    </p:xslt-->
    <!--p:validate-with-schematron>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
        <p:input port="schema">
            <p:document href="../schemas/epub30/epub-nav-30.sch"/>
        </p:input>
    </p:validate-with-schematron-->
    <p:store name="store">
        <p:with-option name="href" select="concat($content-dir,'navigation.xhtml')"/>
    </p:store>

</p:declare-step>
