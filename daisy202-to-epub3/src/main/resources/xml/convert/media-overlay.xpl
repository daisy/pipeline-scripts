<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:d="http://www.daisy.org/ns/pipeline/data" xmlns:mo="http://www.w3.org/ns/SMIL"
    xmlns:epub="http://www.idpf.org/2007/ops" type="pxi:daisy202-to-epub3-mediaoverlay" name="mediaoverlay" version="1.0">

    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
        <p px:role="desc">For processing the SMILs.</p>
    </p:documentation>

    <p:input port="daisy-smil" sequence="true" primary="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The DAISY 2.02 SMIL-files.</p:documentation>
    </p:input>
    <p:input port="content" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The EPUB3 Content Documents.</p:documentation>
    </p:input>

    <p:output port="mediaoverlay" sequence="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">The EPUB3 Media Overlays.</p:documentation>
    </p:output>

    <p:option name="daisy-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="name">URI to the DAISY 2.02 files.</p>
            <pre><code class="example">file:/home/user/daisy202/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="publication-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">URI to the EPUB3 Publication directory.</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="content-dir" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="name">URI to the EPUB3 Content directory.</p>
            <pre><code class="example">file:/home/user/epub3/epub/Publication/Content/</code></pre>
        </p:documentation>
    </p:option>
    <p:option name="include-mediaoverlay" required="true">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">
            <p px:role="desc">Whether or not to include media overlays. Can be either 'true' or 'false'.</p>
        </p:documentation>
    </p:option>

    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/fileset-utils/library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For manipulating filesets.</p:documentation>
    </p:import>
    <p:import href="http://www.daisy.org/pipeline/modules/mediaoverlay-utils/library.xpl">
        <p:documentation xmlns="http://www.w3.org/1999/xhtml">For manipulating media overlays.</p:documentation>
    </p:import>

    <p:declare-step type="pxi:fix-textrefs">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:viewport match="/*//mo:seq[@epub:textref]">
            <p:add-attribute match="/*" attribute-name="epub:textref">
                <p:with-option name="attribute-value" select="/*/@epub:textref/replace(.,'^(.+)\.[^\.]*#(.*)$','$1.xhtml#$2')"/>
            </p:add-attribute>
            <pxi:fix-textrefs/>
        </p:viewport>
    </p:declare-step>

    <p:for-each name="daisy-smil-iterate">
        <p:iteration-source>
            <p:pipe port="daisy-smil" step="mediaoverlay"/>
        </p:iteration-source>
        <p:variable name="original-uri" select="base-uri(/*)"/>
        <px:mediaoverlay-upgrade-smil/>
        <px:message>
            <p:with-option name="message" select="concat('upgraded the SMIL file ',$original-uri)"/>
        </px:message>
        <p:add-attribute match="/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="$original-uri"/>
        </p:add-attribute>
    </p:for-each>
    <px:mediaoverlay-join name="mediaoverlay-joined"/>
    <px:message>
        <p:with-option name="message" select="'joined all the media overlays'"/>
    </px:message>
    <p:sink/>

    <p:choose>
        <p:when test="$include-mediaoverlay='true'">
            <p:xpath-context>
                <p:empty/>
            </p:xpath-context>

            <p:for-each>
                <p:iteration-source>
                    <p:pipe port="content" step="mediaoverlay"/>
                </p:iteration-source>
                <p:variable name="content-result-uri" select="base-uri(/*)"/>
                <p:variable name="result-uri" select="replace($content-result-uri,'xhtml$','smil')"/>

                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="/*/@original-href"/>
                </p:add-attribute>
                <p:add-attribute match="/*" attribute-name="original-href">
                    <p:with-option name="attribute-value" select="$result-uri"/>
                </p:add-attribute>
            </p:for-each>
            <p:identity name="content"/>

            <px:mediaoverlay-rearrange>
                <p:input port="mediaoverlay">
                    <p:pipe port="result" step="mediaoverlay-joined"/>
                </p:input>
                <p:input port="content">
                    <p:pipe port="result" step="content"/>
                </p:input>
            </px:mediaoverlay-rearrange>

            <p:for-each>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="/*/@original-href"/>
                </p:add-attribute>
                <!--<p:delete match="/*/@xml:base"/>-->
                <p:xslt name="rearrange.mediaoverlay-annotated">
                    <p:input port="parameters">
                        <p:empty/>
                    </p:input>
                    <p:input port="stylesheet">
                        <p:inline>
                            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:mo="http://www.w3.org/ns/SMIL">
                                <xsl:template match="@*|node()">
                                    <xsl:copy>
                                        <xsl:apply-templates select="@*|node()"/>
                                    </xsl:copy>
                                </xsl:template>
                                <xsl:template match="mo:text">
                                    <xsl:copy>
                                        <xsl:copy-of select="@*"/>
                                        <xsl:attribute name="src" select="replace(@src,'^(.+)\.[^\.]*#(.*)$','$1.xhtml#$2')"/>
                                        <xsl:apply-templates select="node()"/>
                                    </xsl:copy>
                                </xsl:template>
                            </xsl:stylesheet>
                        </p:inline>
                    </p:input>
                </p:xslt>
                <pxi:fix-textrefs/>
            </p:for-each>

        </p:when>
        <p:otherwise>
            <p:identity>
                <p:input port="source">
                    <p:empty/>
                </p:input>
            </p:identity>
        </p:otherwise>
    </p:choose>

</p:declare-step>
